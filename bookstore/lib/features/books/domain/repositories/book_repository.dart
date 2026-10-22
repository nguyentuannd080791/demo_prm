import '../entities/book.dart';
import '../entities/book_filter_params.dart';
import '../entities/create_book_params.dart';

abstract class BookRepository {
  /// Lấy danh sách sách từ hệ thống kèm các tiêu chí lọc/tìm kiếm (nếu có).
  Future<List<Book>> getBooks([BookFilterParams? params]);

  /// Thêm sách mới vào hệ thống và lưu vào cơ sở dữ liệu.
  Future<Book> createBook(CreateBookParams params);

  /// Cập nhật thông tin sách hiện có.
  Future<Book> updateBook(int id, CreateBookParams params);

  /// Xóa sách khỏi hệ thống theo ID.
  Future<void> deleteBook(int id);
}
