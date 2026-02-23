import '../models/book.dart';
import '../models/borrow_item.dart';
import '../utils/generic_utils.dart';

class BorrowService {
  final List<BorrowItem> _borrowItems = <BorrowItem>[];

  List<BorrowItem> getAll() => _borrowItems;

  bool get isEmpty => _borrowItems.isEmpty;

  void clear() => _borrowItems.clear();

  void printBorrowList() {
    for (int i = 0; i < _borrowItems.length; i++) {
      final BorrowItem item = _borrowItems[i];
      print(
        '${i + 1}. ${item.book.title} | ${item.book.rentalFee}원 | '
        '${item.count}권 | 소계 ${item.subtotalFee()}원',
      );
    }
    print('총 권수: ${totalBorrowedCount()}권');
    print('총 대여료: ${totalRentalFee()}원');
  }

  /// TODO(10): Generic findFirst를 사용해 bookId로 BorrowItem 찾기
  BorrowItem? findBorrowItemByBookId(int bookId) {
    // TODO: 구현
    return findFirst<BorrowItem>(
      _borrowItems,
      (item) => item.book.id == bookId,
    );
  }

  /// TODO(11): 대여 바구니 담기
  /// 규칙:
  /// - count는 1 이상
  /// - (기존 담긴 수량 + count) <= book.stock
  /// - 담은 뒤 총 권수(totalBorrowedCount)가 maxBorrowLimit 초과하면 거부
  /// - 이미 담긴 책이면 누적, 아니면 신규 추가
  void add({
    required Book book,
    required int count,
    required int maxBorrowLimit,
  }) {
    // TODO: 구현
    // 1) 이미 담겨있는지 확인
    final existingItem = findBorrowItemByBookId(book.id);
    int totalBorrowedCount = existingItem?.count ?? 0;
    // 2) 재고 확인(기존 수량 + 새로 추가할 수량)
    if (totalBorrowedCount + count > book.stock) {
      print('재고가 부족합니다. 남은 재고: ${book.stock}개 | 장바구니: $totalBorrowedCount개');
    } else if (totalBorrowedCount + count > maxBorrowLimit) {
      print('최대 대여 가능한 권수 이상입니다.');
      return;
    }
    // 3) 추가 또는 누적
    if (existingItem != null) {
      // 장바구니안에 있으면 추가
      existingItem.count += count;
    } else {
      // 없으면 새로 추가
      _borrowItems.add(BorrowItem(book: book, count: count));
    }
  }

  /// TODO(12): 수량 변경/삭제
  /// 규칙:
  /// - borrowItemIndex 범위 체크
  /// - newCount == 0 -> removeAt
  /// - newCount >= 1 -> 변경
  /// - newCount <= book.stock 초과 금지
  /// - 변경 후 총 권수(totalBorrowedCount)가 maxBorrowLimit 초과하면 거부
  void updateCount({
    required int borrowItemIndex,
    required int newCount,
    required int maxBorrowLimit,
  }) {
    // TODO: 구현. 인덱스 순서를 이용해서 특정 항목을 고치거나 지우는 로직
    if (borrowItemIndex < 0 || borrowItemIndex >= _borrowItems.length) return;

    final item = _borrowItems[borrowItemIndex];
    if (newCount <= 0) {
      _borrowItems.removeAt(borrowItemIndex);
      print('해당 도서를 삭제했습니다.');
    } else if (newCount > item.book.stock) {
      // 재고 초과 시
      print('재고를 초과했습니다. 현재 재고량: ${item.book.stock}');
    } else {
      // 수량 변경
      item.count = newCount;
      print('${item.book.title}의 수량이 $newCount개로 변경되었습니다.');
      return;
    }

    if (maxBorrowLimit < totalBorrowedCount()) {
      print('총 대여권수가 최대 대여가능 권수 이상입니다.');
      return;
    }
  }

  /// TODO(13): Generic sumBy로 총 권수 계산
  int totalBorrowedCount() {
    // TODO: 구현
    return sumBy(_borrowItems, (item) => item.count);
  }

  /// TODO(14): Generic sumBy로 총 대여료 계산
  int totalRentalFee() {
    // TODO: 구현
    return sumBy(_borrowItems, (item) => item.subtotalFee());
  }
}
