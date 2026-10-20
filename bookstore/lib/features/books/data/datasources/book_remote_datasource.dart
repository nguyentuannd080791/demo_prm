import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/create_book_params.dart';
import '../models/book_model.dart';

class BookRemoteDataSource {
  BookRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<BookModel>> fetchBooks() async {
    final json = await _client.get(ApiEndpoints.books) as List<dynamic>;
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
}
