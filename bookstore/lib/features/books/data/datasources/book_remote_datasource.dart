import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/book_filter_params.dart';
import '../../domain/entities/create_book_params.dart';
import '../models/book_model.dart';

class BookRemoteDataSource {
  BookRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<BookModel>> fetchBooks([BookFilterParams? params]) async {
    final query = params?.toQueryParameters();
    final json = await _client.get(
      ApiEndpoints.books,
      queryParameters: query,
    ) as List<dynamic>;
    return json
        .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookModel> createBook(CreateBookParams params) async {
    final response = await _client.post(
      ApiEndpoints.books,
      body: params.toJson(),
    ) as Map<String, dynamic>;
    return BookModel.fromJson(response);
  }

  Future<BookModel> updateBook(int id, CreateBookParams params) async {
    final response = await _client.put(
      '${ApiEndpoints.books}/$id',
      body: params.toJson(),
    ) as Map<String, dynamic>;
    return BookModel.fromJson(response);
  }

  Future<void> deleteBook(int id) async {
    await _client.delete('${ApiEndpoints.books}/$id');
  }
}
