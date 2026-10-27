import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_filter_params.dart';
import '../../domain/entities/create_book_params.dart';
import '../../domain/repositories/book_repository.dart';

class BookProvider extends ChangeNotifier {
  BookProvider(this._repository);

  final BookRepository _repository;

  List<Book> _books = const [];
  BookFilterParams _filterParams = const BookFilterParams();
  bool _isLoading = true;
  String? _error;

  List<Book> get books => _books;
  BookFilterParams get filterParams => _filterParams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? bookNameOf(int bookId) {
    for (final book in _books) {
      if (book.bookId == bookId) return book.bookName;
    }
    return null;
  }

  /// Nạp danh sách sách theo các tiêu chí tìm kiếm/lọc.
  /// Nếu [isAdmin] == false (người dùng bình thường): bắt buộc chỉ lấy sách đang bán (status = ACTIVE).
  Future<void> loadBooks({
    BookFilterParams? params,
    bool isAdmin = true,
  }) async {
    if (params != null) {
      _filterParams = params;
    }
    // Khách hàng bình thường không bao giờ thấy sách hết hàng
    if (!isAdmin) {
      _filterParams = _filterParams.copyWith(status: 'ALL');
    }

    debugPrint("[Filter Status] ${_filterParams.status}");

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await _repository.getBooks(_filterParams);
      if (!isAdmin) {
        _books = fetched.where((b) => b.status && b.stockQuantity > 0).toList();
      } else {
        _books = fetched;
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Không tải được danh sách sách';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyFilters(BookFilterParams params, {bool isAdmin = true}) {
    loadBooks(params: params, isAdmin: isAdmin);
  }

  void resetFilters({bool isAdmin = true}) {
    loadBooks(
      params: BookFilterParams(status: isAdmin ? null : 'ACTIVE'),
      isAdmin: isAdmin,
    );
  }

  Future<Book> createBook(CreateBookParams params) async {
    final newBook = await _repository.createBook(params);
    await loadBooks();
    return newBook;
  }

  Future<Book> updateBook(int id, CreateBookParams params) async {
    final updated = await _repository.updateBook(id, params);
    await loadBooks();
    return updated;
  }

  Future<void> deleteBook(int id) async {
    await _repository.deleteBook(id);
    await loadBooks();
  }
}
