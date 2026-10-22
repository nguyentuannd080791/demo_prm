import '../../domain/entities/register_params.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<User> login({required String username, required String password}) async {
    final result = await _remote.login(username, password);
    await _local.saveSession(result.token, result.user);
    return result.user;
  }

  @override
  Future<User> register(RegisterParams params) async {
    await _remote.register(params);
    return login(username: params.username, password: params.password);
  }

  @override
  Future<User?> restoreSession() async {
    final token = await _local.readToken();
    if (token == null || token.isEmpty) return null;
    final user = _local.readUser();
    if (user == null) {
      await _local.clear();
      return null;
    }
    return user;
  }

  @override
  Future<void> logout() => _local.clear();
}
