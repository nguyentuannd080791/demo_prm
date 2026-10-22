import 'package:flutter/material.dart';

/// Thanh điều khiển trạng thái mở bán của sách (Mở bán / Tạm ngừng bán)
class BookStatusCard extends StatelessWidget {
  const BookStatusCard({
    super.key,
    required this.status,
    required this.onChanged,
  });

  final bool status;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: status
          ? Colors.green.withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: status
              ? Colors.green.shade400.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: SwitchListTile(
        value: status,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        secondary: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: status
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            status ? Icons.storefront : Icons.storefront_outlined,
            color: status ? Colors.green.shade700 : Colors.grey.shade600,
            size: 22,
          ),
        ),
        title: const Text(
          'Mở bán sản phẩm',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          status
              ? 'Đang mở bán (Hiển thị sách cho khách hàng)'
              : 'Tạm ngừng bán (Ẩn sách với khách hàng)',
          style: TextStyle(
            fontSize: 12.5,
            color: status ? Colors.green.shade700 : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
