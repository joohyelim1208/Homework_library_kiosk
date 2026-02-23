import 'dart:io';

import 'package:dart_library_kiosk/services/police_service.dart';

import 'enums/enums.dart';
import 'models/book.dart';
import 'repository/book_repository.dart';
import 'services/borrow_service.dart';

import 'utils/console_io.dart';

void main() {
  final BookRepository bookRepository = BookRepository(seedBooks: _seedBooks());

  final BorrowService borrowService = BorrowService();
  final PolicyService policyService = PolicyService();

  final LibraryApp libraryApp = LibraryApp(
    bookRepository: bookRepository,
    borrowService: borrowService,
    policyService: policyService,
  );

  libraryApp.run();
}

List<Book> _seedBooks() {
  return <Book>[
    Book(id: 1, title: '클린 코드', rentalFee: 4500, stock: 5),
    Book(id: 2, title: '리팩터링', rentalFee: 5200, stock: 2),
    Book(id: 3, title: '이펙티브 다트', rentalFee: 4800, stock: 0),
    Book(id: 4, title: '객체지향의 사실과 오해', rentalFee: 3900, stock: 3),
    Book(id: 5, title: '코딩 테스트 합격자 되기', rentalFee: 3500, stock: 10),
  ];
}

class LibraryApp {
  final BookRepository bookRepository;
  final BorrowService borrowService;
  final PolicyService policyService;

  MemberTier selectedMemberTier = MemberTier.guest;

  LibraryApp({
    required this.bookRepository,
    required this.borrowService,
    required this.policyService,
  });

  void run() {
    while (true) {
      _printMainMenu();
      final int? input = ConsoleIO.readIntOrNull();

      switch (input) {
        case 1:
          _showBookList();
          break;
        case 2:
          _addToBorrowListFlow();
          break;
        case 3:
          _manageBorrowListFlow();
          break;
        case 4:
          _selectMemberTierFlow();
          break;
        case 5:
          _confirmBorrowFlow();
          break;
        case 0:
          print('프로그램을 종료합니다.');
          return;
        default:
          print('잘못된 입력입니다.');
      }
    }
  }

  void _printMainMenu() {
    print('\n========== 📚 LIBRARY KIOSK ==========');
    print('회원 등급: ${_memberTierText(selectedMemberTier)}');
    print('1. 도서 목록 보기');
    print('2. 대여 바구니 담기');
    print('3. 대여 바구니 보기 및 수량 변경/삭제');
    print('4. 회원 등급 선택');
    print('5. 대여 확정(결제)');
    print('0. 종료');
    print('=====================================');
    stdout.write('메뉴 번호 입력: ');
  }

  void _showBookList() {
    print('\n[도서 목록]');
    for (final Book book in bookRepository.getAll()) {
      print(book.displayText());
    }
  }

  void _addToBorrowListFlow() {
    print('\n[대여 바구니 담기]');
    _showBookList();

    final int bookId = ConsoleIO.readPositiveInt('대여할 도서 번호');
    final int count = ConsoleIO.readPositiveInt('대여할 권수');

    final Book? selectedBook = bookRepository.findById(bookId);
    if (selectedBook == null) {
      print('존재하지 않는 도서 번호입니다.');
      return;
    }

    // TODO(1): 품절 도서는 담을 수 없게 막기
    // 힌트: selectedBook.status == BookStatus.outOfStock
    if (selectedBook.status == BookStatus.outOfStock) {
      print('선택하신 ${selectedBook.title}은 현재 품절입니다.');
    }
    // 투두15 등급별 대여가능 권수 반환
    final int maxBorrowLimit = policyService.borrowLimitForTier(
      selectedMemberTier,
    );

    // TODO(2): borrowService.add(...) 호출
    // - 재고 초과 방지: borrowService에서 함수작성
    // - 등급별 대여 가능 권수(maxBorrowLimit) 초과 방지
    // - 이미 담긴 도서면 누적

    borrowService.add(
      book: selectedBook,
      count: count,
      maxBorrowLimit: maxBorrowLimit,
    );
  }

  void _manageBorrowListFlow() {
    if (borrowService.isEmpty) {
      print('대여 바구니가 비어있습니다.');
      return;
    }

    print('\n[대여 바구니]');
    borrowService.printBorrowList();

    stdout.write('수량을 변경하시겠습니까? (y/n): ');
    final String input = (stdin.readLineSync() ?? '').trim().toLowerCase();
    if (input != 'y') return;

    final int itemNumber = ConsoleIO.readPositiveInt('변경할 항목 번호');
    final int borrowItemIndex = itemNumber - 1;

    stdout.write('새 권수 입력 (0이면 삭제): ');
    final int? newCount = ConsoleIO.readIntOrNull();
    if (newCount == null || newCount < 0) {
      print('잘못된 입력입니다.');
      return;
    }

    final int maxBorrowLimit = policyService.borrowLimitForTier(
      // enum MemberTier 값. 등급별 대여가능 권수 반환
      selectedMemberTier,
    );

    // TODO(3): borrowService.updateCount(...) 호출
    // - 인덱스 범위 체크
    // - 0이면 삭제
    // - 재고 초과 방지
    // - 등급별 대여 가능 권수(maxBorrowLimit) 초과 방지

    borrowService.updateCount(
      borrowItemIndex: borrowItemIndex,
      newCount: newCount,
      maxBorrowLimit: maxBorrowLimit,
    );
  }

  void _selectMemberTierFlow() {
    print('\n[회원 등급 선택]');
    print('1. GUEST (대여 2권, 할인 0%)');
    print('2. STANDARD (대여 4권, 할인 5%)');
    print('3. PREMIUM (대여 6권, 할인 10%)');
    stdout.write('선택: ');

    final int? input = ConsoleIO.readIntOrNull();
    switch (input) {
      case 1:
        selectedMemberTier = MemberTier.guest;
        break;
      case 2:
        selectedMemberTier = MemberTier.standard;
        break;
      case 3:
        selectedMemberTier = MemberTier.premium;
        break;
      default:
        print('잘못된 입력입니다.');
        return;
    }

    print('회원 등급이 ${_memberTierText(selectedMemberTier)}로 설정되었습니다.');

    // TODO(4) (선택): 등급이 내려갔을 때 이미 담긴 총 권수가 제한을 넘으면 안내하기
    // 힌트: borrowService.totalBorrowedCount() 와 policyService.borrowLimitForTier(...) 비교. 총 대여권수와 등급별 할인율
    final int currentTotalCount = borrowService
        .totalBorrowedCount(); // 현재 빌린 장바구니 총 권수
    final int finalTier = policyService.borrowLimitForTier(selectedMemberTier);

    if (currentTotalCount > finalTier) {
      print('장바구니에 담긴 총 도서 수: $currentTotalCount가 대여제한 권수 $finalTier을 초과했습니다.');
    }
  }

  void _confirmBorrowFlow() {
    if (borrowService.isEmpty) {
      print('확정할 대여 항목이 없습니다.');
      return;
    }

    final int originalTotalFee = borrowService.totalRentalFee();
    final int finalTotalFee = policyService.calculateFinalRentalFee(
      originalTotalFee: originalTotalFee,
      memberTier: selectedMemberTier,
    );

    print('\n[대여 확정]');
    print('회원 등급: ${_memberTierText(selectedMemberTier)}');
    print('총 권수: ${borrowService.totalBorrowedCount()}권');
    print('대여료(원가): ${originalTotalFee}원');
    print('대여료(할인 후): ${finalTotalFee}원');

    stdout.write('대여를 확정하시겠습니까? (y/n): ');
    final String confirm = (stdin.readLineSync() ?? '').trim().toLowerCase();
    if (confirm != 'y') {
      print('대여 확정이 취소되었습니다.');
      return;
    }

    // TODO(5): 확정 시 재고 차감
    // - borrowService.getAll() 순회. 장바구니에 담긴 모든 아이템을 가져옴.
    // - 각 item.book.decreaseStock(item.count) 호출. 장바구니 속 아이템을 하나씩 가져와서 호출
    // - decreaseStock 내부에서 status 갱신되도록 구현
    final items = borrowService.getAll();
    for (var item in items) {
      item.book.decreaseStock(item.count);
    }
    // TODO(6): borrowService.clear()
    borrowService.clear();

    print('대여가 완료되었습니다. 반납 기한을 지켜주세요!');
  }

  String _memberTierText(MemberTier memberTier) {
    switch (memberTier) {
      case MemberTier.guest:
        return 'GUEST';
      case MemberTier.standard:
        return 'STANDARD';
      case MemberTier.premium:
        return 'PREMIUM';
    }
  }
}
