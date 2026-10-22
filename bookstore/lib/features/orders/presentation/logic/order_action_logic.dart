import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';
import '../widgets/cancel_order_dialog.dart';

/// Lớp xử lý tập trung toàn bộ các tác vụ thay đổi trạng thái đơn hàng (SOLID SRP & DRY)
/// Dùng chung cho cả AdminOrderListPage, OrderDetailPage và OrderTile.
class OrderActionLogic {
  const OrderActionLogic._();

  /// Phê duyệt đơn hàng (Admin/Staff)
  static Future<void> handleApprove(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) async {
    final displayName = order.receiverName.isNotEmpty ? order.receiverName : 'Người dùng';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Phê duyệt đơn hàng'),
        content: Text(
          'Xác nhận phê duyệt đơn hàng #${order.id} của khách hàng $displayName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Phê duyệt'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final error = await context.read<OrderProvider>().approveOrder(order.id);
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã phê duyệt đơn hàng #${order.id} thành công!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        onSuccess?.call();
      }
    }
  }

  /// Từ chối đơn hàng kèm lý do (Admin/Staff)
  static Future<void> handleReject(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc muốn từ chối đơn hàng #${order.id}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do từ chối (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final error = await context.read<OrderProvider>().rejectOrder(
            order.id,
            reason: reasonController.text.trim(),
          );
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã từ chối đơn hàng #${order.id}'),
            backgroundColor: Colors.orange.shade800,
          ),
        );
        onSuccess?.call();
      }
    }
  }

  /// Bắt đầu giao đơn hàng (Admin/Staff)
  static Future<void> handleShip(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Giao hàng'),
        content: Text(
          'Chuyển trạng thái đơn hàng #${order.id} sang "Đang giao hàng"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận giao'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final error = await context.read<OrderProvider>().shipOrder(order.id);
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đơn hàng #${order.id} đang được giao!'),
            backgroundColor: Colors.blue.shade700,
          ),
        );
        onSuccess?.call();
      }
    }
  }

  /// Hoàn thành đơn hàng (Admin/Staff)
  static Future<void> handleComplete(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hoàn thành đơn hàng'),
        content: Text(
          'Xác nhận đơn hàng #${order.id} đã được giao thành công cho khách hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final error = await context.read<OrderProvider>().completeOrder(order.id);
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đơn hàng #${order.id} đã hoàn thành!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        onSuccess?.call();
      }
    }
  }

  /// Hủy đơn hàng (Khách hàng hoặc Admin)
  static Future<void> handleCancel(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) async {
    final result = await CancelOrderDialog.show(context, order.id);
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã hủy đơn hàng #${order.id} thành công'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      onSuccess?.call();
    }
  }
}
