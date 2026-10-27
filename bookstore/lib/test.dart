class Calculator {
  static int divide(num a, num b) {
    if (b == 0) {
      throw ArgumentError('Số chia không thể bằng 0');
    }
    return a ~/ b;
  }
}
