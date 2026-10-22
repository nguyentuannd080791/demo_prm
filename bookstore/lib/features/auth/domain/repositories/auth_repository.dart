import '../entities/register_params.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});

  /// Đăng ký xong sẽ tự đăng nhập.
  Future<User> register(RegisterParams params);

  Future<User?> restoreSession();

  Future<void> logout();
}
