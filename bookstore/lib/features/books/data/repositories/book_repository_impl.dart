import '../../domain/entities/book.dart';
import '../../domain/entities/book_filter_params.dart';
import '../../domain/entities/create_book_params.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl(this._remote);

  final BookRemoteDataSource _remote;

  @override
  Future<List<Book>> getBooks([BookFilterParams? params]) async {
    return _remote.fetchBooks(params);
  }

  @override
  Future<Book> createBook(CreateBookParams params) {
    return _remote.createBook(params);
  }

  @override
  Future<Book> updateBook(int id, CreateBookParams params) {
    return _remote.updateBook(id, params);
  }

  @override
  Future<void> deleteBook(int id) {
    return _remote.deleteBook(id);
  }
}
