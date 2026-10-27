import 'package:flutter_test/flutter_test.dart';
import 'package:bookstore/test.dart';

void main() {
  group('Kiểm thử phép chia (Calculator.divide)', () {
    test('Chia 2 số dương hợp lệ với matcher equals', () {
      final result = Calculator.divide(10, 2);
      expect(result, equals(5));
    });

    test('Chia số âm hợp lệ', () {
      final result = Calculator.divide(-15, 3);
      expect(result, equals(-5));
    });

    test('Chia ra số thập phân với matcher closeTo', () {
      final result = Calculator.divide(10, 3);
      expect(result, equals(3));
    });

    test(
      'Chia cho 0 phải ném ngoại lệ sử dụng matcher throwsA kết hợp expect',
      () {
        expect(() => Calculator.divide(10, 0), throwsA(isA<ArgumentError>()));
      },
    );

    test(
      'Kiểm tra chi tiết kiểu và thông điệp lỗi của Exception khi chia cho 0',
      () {
        expect(
          () => Calculator.divide(5, 0),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Số chia không thể bằng 0',
            ),
          ),
        );
      },
    );
  });
}
