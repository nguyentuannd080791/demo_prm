import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/register_page.dart';
import '../providers/auth_provider.dart';

/// Lớp xử lý toàn bộ logic cho LoginPage (SOLID SRP)
/// Quản lý controller, toggle mật khẩu, gọi API đăng nhập và điều hướng.
class LoginLogic extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isSubmitting = false;
  String? error;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting = true;
    error = null;
    notifyListeners();

    final resultError = await context.read<AuthProvider>().login(
          usernameController.text.trim(),
          passwordController.text,
        );

    // Đăng nhập thành công: AuthGate thay trang này nên widget có thể bị hủy
    if (!context.mounted) return;

    isSubmitting = false;
    error = resultError;
    notifyListeners();
  }

  void openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
