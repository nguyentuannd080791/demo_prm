import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/register_params.dart';
import '../providers/auth_provider.dart';

/// Lớp xử lý toàn bộ logic cho RegisterPage (SOLID SRP)
/// Quản lý controller, toggle mật khẩu, validation confirm password, gọi API đăng ký và điều hướng.
class RegisterLogic extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isSubmitting = false;
  String? error;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting = true;
    error = null;
    notifyListeners();

    final params = RegisterParams(
      fullName: fullNameController.text,
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
    );

    final resultError = await context.read<AuthProvider>().register(params);

    if (!context.mounted) return;

    if (resultError == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    isSubmitting = false;
    error = resultError;
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
