class RegisterParams {
  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String username;
  final String email;
  final String password;
  final String fullName;

  /// Chuyển đổi sang Map JSON tương thích với endpoint POST /api/auth/register của backend
  Map<String, dynamic> toJson() => {
        'username': username.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'fullName': fullName.trim(),
      };
}
