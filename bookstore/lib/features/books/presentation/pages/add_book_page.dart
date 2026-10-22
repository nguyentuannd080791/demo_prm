import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/book.dart';
import '../providers/add_book_controller.dart';
import '../providers/book_provider.dart';
import '../widgets/book_status_card.dart';
import '../widgets/book_text_field.dart';
import '../widgets/submit_book_button.dart';

/// Trang tạo hoặc chỉnh sửa sách
/// Áp dụng SOLID: Tách biệt logic sang [AddBookController]
class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key, this.book});

  final Book? book;

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  late final AddBookController _controller;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    _controller = AddBookController();
    if (_isEditing) {
      _controller.initFromBook(widget.book!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    try {
      final bookProvider = context.read<BookProvider>();
      final book = await _controller.submit(
        bookProvider,
        editBookId: widget.book?.bookId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEditing
                      ? 'Đã cập nhật thành công sách "${book.bookName}"!'
                      : 'Đã thêm thành công sách "${book.bookName}"!',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_isEditing ? "Cập nhật" : "Thêm"} sách thất bại: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa sách' : 'Thêm sách mới'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tên sách
                BookTextField(
                  controller: _controller.nameController,
                  labelText: 'Tên sách *',
                  hintText: 'Nhập tên cuốn sách...',
                  prefixIcon: Icons.book_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tên sách';
                    }
                    if (val.trim().length < 2) {
                      return 'Tên sách phải có ít nhất 2 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tác giả
                BookTextField(
                  controller: _controller.authorController,
                  labelText: 'Tác giả *',
                  hintText: 'Ví dụ: Robert C. Martin',
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tên tác giả';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nhà xuất bản
                BookTextField(
                  controller: _controller.publisherController,
                  labelText: 'Nhà xuất bản *',
                  hintText: 'Ví dụ: NXB Trẻ, NXB Kim Đồng...',
                  prefixIcon: Icons.business_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập nhà xuất bản';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Giá bán
                BookTextField(
                  controller: _controller.priceController,
                  labelText: 'Giá bán (VNĐ) *',
                  hintText: 'Ví dụ: 120000',
                  prefixIcon: Icons.attach_money,
                  suffixText: '₫',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập giá bán';
                    }
                    final p = double.tryParse(val.trim());
                    if (p == null || p < 0) {
                      return 'Giá bán phải là số hợp lệ >= 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Số lượng sách (Tồn kho)
                BookTextField(
                  controller: _controller.stockQuantityController,
                  labelText: 'Số lượng sách *',
                  hintText: 'Ví dụ: 50',
                  prefixIcon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập số lượng sách';
                    }
                    final s = int.tryParse(val.trim());
                    if (s == null || s < 0) {
                      return 'Số lượng sách phải là số nguyên >= 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tóm tắt nội dung
                BookTextField(
                  controller: _controller.summaryController,
                  labelText: 'Tóm tắt nội dung *',
                  hintText: 'Nhập tóm tắt, mô tả ngắn gọn về sách...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  alignLabelWithHint: true,
                  textInputAction: TextInputAction.newline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tóm tắt nội dung sách';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Thanh mở bán
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => BookStatusCard(
                    status: _controller.status,
                    onChanged: _controller.setStatus,
                  ),
                ),
                const SizedBox(height: 28),

                // Nút Submit
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => SubmitBookButton(
                    isSubmitting: _controller.isSubmitting,
                    onPressed: _handleSubmit,
                    label: _isEditing ? 'Lưu thay đổi' : 'Tạo sách mới',
                    icon: _isEditing ? Icons.save_outlined : Icons.add_task,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
