import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/create_book_params.dart';
import '../../domain/repositories/book_repository.dart';

class BookProvider extends ChangeNotifier {
  BookProvider(this._repository);

  final BookRepository _repository;

  List<Book> _books = const [];
  bool _isLoading = true;
  String? _error;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? bookNameOf(int bookId) {
    for (final book in _books) {
      if (book.bookId == bookId) return book.bookName;
    }
    return null;
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _books = await _repository.getBooks();
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Không tải được danh sách sách';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Book> createBook(CreateBookParams params) async {
    final newBook = await _repository.createBook(params);
    await loadBooks();
    return newBook;
  }
}
