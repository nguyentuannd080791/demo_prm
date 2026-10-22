import 'package:flutter/material.dart';

/// Nút bấm gửi biểu mẫu tạo/sửa sách có hiển thị trạng thái loading
class SubmitBookButton extends StatelessWidget {
  const SubmitBookButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
    this.label,
    this.icon,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isSubmitting ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon ?? Icons.add_task),
      label: Text(
        isSubmitting
            ? 'Đang lưu vào hệ thống...'
            : (label ?? 'Tạo sách mới'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
