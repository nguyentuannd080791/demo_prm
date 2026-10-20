import '../../domain/entities/book.dart';
import '../../domain/entities/create_book_params.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl(this._remote);

  final BookRemoteDataSource _remote;

  @override
  Future<List<Book>> getBooks() async {
    return _remote.fetchBooks();
  }

  @override
  Future<Book> createBook(CreateBookParams params) {
    return _remote.createBook(params);
  }
}
