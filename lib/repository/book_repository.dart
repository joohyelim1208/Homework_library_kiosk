import '../models/book.dart';
import '../utils/generic_utils.dart';

class BookRepository {
  final List<Book> _books;

  BookRepository({required List<Book> seedBooks}) : _books = seedBooks;

  List<Book> getAll() => _books;

  /// TODO(9): Generic findFirst를 사용해 id로 책 찾기
  Book? findById(int id) {
    // TODO: 구현
    return findFirst<Book>(_books, (item) => item.id == id);
  }
}
