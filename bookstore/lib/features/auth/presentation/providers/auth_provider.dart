import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> restoreSession() async {
    _user = await _repository.restoreSession();
    notifyListeners();
  }

  Future<String?> login(String username, String password) {
    return _authenticate(
      () => _repository.login(username: username, password: password),
    );
  }

  Future<String?> register(RegisterParams params) {
    return _authenticate(
      () => _repository.register(params),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  Future<String?> _authenticate(Future<User> Function() action) async {
    try {
      _user = await action();
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Đã có lỗi xảy ra, vui lòng thử lại';
    }
  }
}
