import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl(this._remote);

  final BookRemoteDataSource _remote;

  @override
  Future<List<Book>> getBooks() async {
    final books = await _remote.fetchBooks();
    return books.where((book) => book.status).toList();
  }
}
