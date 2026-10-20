import '../entities/book.dart';
import '../entities/create_book_params.dart';

abstract class BookRepository {
  /// Lấy toàn bộ danh sách sách từ hệ thống (bao gồm cả sách đang bán và hết hàng).
  Future<List<Book>> getBooks();

  /// Thêm sách mới vào hệ thống và lưu vào cơ sở dữ liệu.
  Future<Book> createBook(CreateBookParams params);
}
