import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});

  /// Đăng ký xong sẽ tự đăng nhập.
  Future<User> register({
    required String username,
    required String password,
  });

  Future<User?> restoreSession();

  Future<void> logout();
}
