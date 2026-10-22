import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books/presentation/providers/book_provider.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';
import 'order_action_logic.dart';

/// Lớp quản lý trạng thái tải chi tiết và điều phối thao tác đơn hàng cho OrderDetailPage (SOLID SRP)
class OrderDetailLogic {
  const OrderDetailLogic();

  void init(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final bookProvider = context.read<BookProvider>();
        if (bookProvider.books.isEmpty) {
          bookProvider.loadBooks();
        }
      }
    });
  }

  Future<Order> fetchOrder(BuildContext context, int orderId) {
    return context.read<OrderProvider>().fetchOrder(orderId);
  }

  Future<void> cancelOrder(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) {
    return OrderActionLogic.handleCancel(context, order, onSuccess: onSuccess);
  }

  Future<void> approveOrder(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) {
    return OrderActionLogic.handleApprove(context, order, onSuccess: onSuccess);
  }

  Future<void> rejectOrder(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) {
    return OrderActionLogic.handleReject(context, order, onSuccess: onSuccess);
  }

  Future<void> shipOrder(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) {
    return OrderActionLogic.handleShip(context, order, onSuccess: onSuccess);
  }

  Future<void> completeOrder(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) {
    return OrderActionLogic.handleComplete(context, order, onSuccess: onSuccess);
  }
}
