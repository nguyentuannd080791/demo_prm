import 'package:flutter/material.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/create_book_params.dart';
import 'book_provider.dart';

/// Controller phụ trách quản lý form state và logic gửi dữ liệu tạo sách mới.
/// Tuân thủ nguyên lý Single Responsibility Principle (SRP) - tách toàn bộ logic ra khỏi UI.
class AddBookController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final authorController = TextEditingController();
  final publisherController = TextEditingController();
  final priceController = TextEditingController();
  final summaryController = TextEditingController();

  bool _status = true;
  bool _isSubmitting = false;

  bool get status => _status;
  bool get isSubmitting => _isSubmitting;

  void setStatus(bool value) {
    if (_status == value) return;
    _status = value;
    notifyListeners();
  }

  /// Kiểm tra dữ liệu và gửi yêu cầu tạo sách thông qua [BookProvider]
  /// Trả về đối tượng [Book] nếu thành công, ném ra ngoại lệ [AppException] nếu có lỗi.
  Future<Book> submit(BookProvider bookProvider) async {
    if (!formKey.currentState!.validate()) {
      throw const AppException('Vui lòng điền đầy đủ và chính xác các thông tin.');
    }

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price < 0) {
      throw const AppException('Giá sách phải là số hợp lệ (>= 0).');
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final params = CreateBookParams(
        bookName: nameController.text.trim(),
        price: price,
        author: authorController.text.trim(),
        publisher: publisherController.text.trim(),
        summary: summaryController.text.trim(),
        status: _status,
      );

      final createdBook = await bookProvider.createBook(params);
      return createdBook;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    authorController.dispose();
    publisherController.dispose();
    priceController.dispose();
    summaryController.dispose();
    super.dispose();
  }
}
