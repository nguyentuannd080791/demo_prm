import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/register_params.dart';
import '../models/user_model.dart';

typedef AuthResult = ({String token, UserModel user});

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthResult> login(String username, String password) async {
    final json = await _client.post(
      ApiEndpoints.login,
      body: {'username': username.trim(), 'password': password},
    ) as Map<String, dynamic>;

    // Backend AuthResponse trả về: accessToken, tokenType, expiresIn, user
    final token = (json['accessToken'] ?? json['token'] ?? username).toString();
    final user = json['user'] is Map<String, dynamic>
        ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
        : UserModel(username: (json['username'] ?? username).toString());

    return (token: token, user: user);
  }

  Future<void> register(RegisterParams params) async {
    await _client.post(
      ApiEndpoints.register,
      body: params.toJson(),
    );
  }
}
