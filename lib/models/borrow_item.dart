import 'book.dart';

class BorrowItem {
  final Book book;
  int count;

  BorrowItem({required this.book, required this.count});

  int subtotalFee() => book.rentalFee * count;
}
