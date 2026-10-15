import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
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
}
