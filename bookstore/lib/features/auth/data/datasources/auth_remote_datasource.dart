import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

typedef AuthResult = ({String token, UserModel user});

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthResult> login(String username, String password) async {
    final json = await _client.post(
      ApiEndpoints.login,
      body: {'username': username, 'password': password},
    ) as Map<String, dynamic>;

    final uname = (json['username'] ?? username).toString();
    final token = (json['token'] ?? uname).toString();
    final user = json['user'] is Map<String, dynamic>
        ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
        : UserModel(username: uname);

    return (token: token, user: user);
  }

  Future<void> register(String username, String password) async {
    await _client.post(
      ApiEndpoints.register,
      body: {'username': username, 'password': password},
    );
  }
}
