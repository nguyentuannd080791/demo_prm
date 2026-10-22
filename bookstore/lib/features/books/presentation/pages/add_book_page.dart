import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/book.dart';
import '../providers/add_book_controller.dart';
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
                const SizedBox(height: 16),

                // Đường dẫn hình ảnh (Image URL)
                BookTextField(
                  controller: _controller.imageUrlController,
                  labelText: 'Đường dẫn ảnh bìa (Image URL)',
                  hintText: 'https://example.com/anh-bia-sach.jpg',
                  prefixIcon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),

                // Xem trước ảnh nếu có URL
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller.imageUrlController,
                  builder: (context, value, _) {
                    final url = value.text.trim();
                    if (url.isEmpty || !url.startsWith('http')) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 50,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 50,
                                height: 65,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Xem trước ảnh bìa sách',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

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
                    onPressed: () => _controller.handleSubmit(
                      context,
                      editBookId: widget.book?.bookId,
                    ),
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
