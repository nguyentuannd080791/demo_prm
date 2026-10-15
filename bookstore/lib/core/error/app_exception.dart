class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
}
