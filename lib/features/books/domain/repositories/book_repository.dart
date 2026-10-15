import '../entities/book.dart';

abstract class BookRepository {
  /// Chỉ trả về sách đang bán (status = true).
  Future<List<Book>> getBooks();
}
