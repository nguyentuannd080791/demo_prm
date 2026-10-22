import 'package:flutter/material.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/create_book_params.dart';
import 'book_provider.dart';

/// Controller phụ trách quản lý form state và logic gửi dữ liệu tạo/sửa sách.
/// Tuân thủ nguyên lý Single Responsibility Principle (SRP) - tách toàn bộ logic ra khỏi UI.
class AddBookController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final authorController = TextEditingController();
  final publisherController = TextEditingController();
  final priceController = TextEditingController();
  final stockQuantityController = TextEditingController(text: '10');
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

  /// Nạp sẵn dữ liệu khi mở form ở chế độ chỉnh sửa (Edit Mode)
  void initFromBook(Book book) {
    nameController.text = book.bookName;
    authorController.text = book.author;
    publisherController.text = book.publisher;
    priceController.text = book.price.toStringAsFixed(0);
    stockQuantityController.text = book.stockQuantity.toString();
    summaryController.text = book.summary;
    _status = book.status;
  }

  /// Kiểm tra dữ liệu và gửi yêu cầu tạo/cập nhật sách thông qua [BookProvider]
  Future<Book> submit(BookProvider bookProvider, {int? editBookId}) async {
    if (!formKey.currentState!.validate()) {
      throw const AppException('Vui lòng điền đầy đủ và chính xác các thông tin.');
    }

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price < 0) {
      throw const AppException('Giá sách phải là số hợp lệ (>= 0).');
    }

    final stock = int.tryParse(stockQuantityController.text.trim());
    if (stock == null || stock < 0) {
      throw const AppException('Số lượng sách phải là số nguyên không âm (>= 0).');
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
        stockQuantity: stock,
        status: _status,
      );

      if (editBookId != null) {
        return await bookProvider.updateBook(editBookId, params);
      } else {
        return await bookProvider.createBook(params);
      }
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
    stockQuantityController.dispose();
    summaryController.dispose();
    super.dispose();
  }
}
