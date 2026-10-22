import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = resolve(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static (String label, Color color, IconData icon) resolve(String status) {
    switch (status.toUpperCase().trim()) {
      case 'PENDING':
        return ('Chờ duyệt', Colors.orange.shade800, Icons.hourglass_top_rounded);
      case 'APPROVED':
        return ('Đã duyệt', Colors.blue.shade700, Icons.check_circle_outline_rounded);
      case 'SHIPPING':
        return ('Đang giao', Colors.indigo.shade600, Icons.local_shipping_outlined);
      case 'COMPLETED':
        return ('Hoàn thành', Colors.green.shade700, Icons.verified_outlined);
      case 'CANCELLED':
        return ('Đã hủy', Colors.grey.shade700, Icons.cancel_outlined);
      case 'REJECTED':
        return ('Bị từ chối', Colors.red.shade700, Icons.block_outlined);
      default:
        return (status, Colors.grey.shade800, Icons.info_outline);
    }
  }
}
