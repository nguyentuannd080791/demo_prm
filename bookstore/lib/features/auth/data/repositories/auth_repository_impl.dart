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
  Future<User> register({
    required String username,
    required String password,
  }) async {
    await _remote.register(username, password);
    return login(username: username, password: password);
  }

  @override
  Future<User?> restoreSession() async {
    final token = await _local.readToken();
    if (token == null) return null;
    return _local.readUser();
  }

  @override
  Future<void> logout() => _local.clear();
}
