import '../enums/enums.dart';

class Book {
  final int id;
  final String title;
  final int rentalFee;

  int stock;
  BookStatus status;

  Book({
    required this.id,
    required this.title,
    required this.rentalFee,
    required this.stock,
  }) : status = stock > 0 ? BookStatus.available : BookStatus.outOfStock;

  /// TODO(7): 재고 차감 + 상태 갱신
  /// - stock -= quantity
  /// - stock < 0 이면 0으로 보정
  /// - refreshStatus 호출
  void decreaseStock(int quantity) {
    // TODO: 구현
    stock -= quantity;
    if (stock < 0) {
      stock = 0;
    }
    refreshStatus();
  }

  /// TODO(8): stock에 따라 status 업데이트
  void refreshStatus() {
    // TODO: 구현
    if (stock <= 0) {
      status = BookStatus.outOfStock;
    } else {
      status = BookStatus.available;
    }
  }

  String displayText() {
    final String statusText = status == BookStatus.available ? '대여가능' : '품절';
    return '$id번: $title | 대여료 ${rentalFee}원 | 재고 ${stock}권 | $statusText';
  }
}
