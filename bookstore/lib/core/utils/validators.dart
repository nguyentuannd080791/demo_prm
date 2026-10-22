class Validators {
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập $label';
    return null;
  }

  static String? username(String? value) {
    final req = required(value, 'tên đăng nhập');
    if (req != null) return req;
    final trimmed = value!.trim();
    if (trimmed.length < 4) return 'Tên đăng nhập tối thiểu 4 ký tự';
    if (trimmed.length > 50) return 'Tên đăng nhập tối đa 50 ký tự';
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'email');
    if (requiredError != null) return requiredError;
    final trimmed = value!.trim();
    if (trimmed.length > 100) return 'Email tối đa 100 ký tự';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return pattern.hasMatch(trimmed) ? null : 'Email không đúng định dạng';
  }

  static String? fullName(String? value) {
    final req = required(value, 'họ và tên');
    if (req != null) return req;
    final trimmed = value!.trim();
    if (trimmed.length > 100) return 'Họ và tên tối đa 100 ký tự';
    return null;
  }

  static String? password(String? value) {
    final req = required(value, 'mật khẩu');
    if (req != null) return req;
    if (value!.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
    if (value.length > 72) return 'Mật khẩu tối đa 72 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final req = required(value, 'xác nhận mật khẩu');
    if (req != null) return req;
    return value == password ? null : 'Mật khẩu xác nhận không khớp';
  }
}
