import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'book_text_field.dart';

/// Card chứa toàn bộ trường nhập liệu cơ bản của một cuốn sách
class BookBasicInfoCard extends StatelessWidget {
  const BookBasicInfoCard({
    super.key,
    required this.nameController,
    required this.authorController,
    required this.publisherController,
    required this.priceController,
    required this.summaryController,
  });

  final TextEditingController nameController;
  final TextEditingController authorController;
  final TextEditingController publisherController;
  final TextEditingController priceController;
  final TextEditingController summaryController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Thông tin cơ bản của sách',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tên sách
            BookTextField(
              controller: nameController,
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
              controller: authorController,
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
              controller: publisherController,
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
              controller: priceController,
              labelText: 'Giá bán (VNĐ) *',
              hintText: 'Ví dụ: 120000',
              prefixIcon: Icons.attach_money,
              suffixText: '₫',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

            // Tóm tắt nội dung
            BookTextField(
              controller: summaryController,
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
          ],
        ),
      ),
    );
  }
}
