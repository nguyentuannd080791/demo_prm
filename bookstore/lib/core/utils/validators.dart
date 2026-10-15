class Validators {
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập $label';
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'email');
    if (requiredError != null) return requiredError;
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return pattern.hasMatch(value!.trim()) ? null : 'Email không hợp lệ';
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    return value == password ? null : 'Mật khẩu xác nhận không khớp';
  }
}
