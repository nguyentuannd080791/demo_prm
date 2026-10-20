import 'package:flutter/material.dart';

/// Card điều khiển trạng thái kinh doanh của sách (Đang mở bán / Tạm ngừng bán)
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        value: status,
        onChanged: onChanged,
        secondary: Icon(
          status ? Icons.check_circle : Icons.pause_circle_outline,
          color: status ? Colors.green : Colors.grey,
        ),
        title: const Text(
          'Trạng thái kinh doanh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          status ? 'Đang mở bán' : 'Tạm ngừng bán',
          style: TextStyle(
            color: status ? Colors.green.shade700 : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
