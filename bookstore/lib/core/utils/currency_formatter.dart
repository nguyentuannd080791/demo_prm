class CurrencyFormatter {
  /// 120000 -> "120.000 ₫"
  static String vnd(double amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '$buffer ₫';
  }
}
