class User {
  const User({
    this.userId,
    required this.username,
    this.email,
    this.role,
    this.fullName,
  });

  final int? userId;
  final String username;
  final String? email;
  final String? role;
  final String? fullName;

  /// Kiểm tra tài khoản có quyền Quản trị viên (ADMIN) hay không
  bool get isAdmin => role?.toUpperCase() == 'ADMIN';
}
