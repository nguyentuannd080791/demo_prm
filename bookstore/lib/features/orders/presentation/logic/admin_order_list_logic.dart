import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/order.dart';
import '../pages/order_detail_page.dart';
import '../providers/order_provider.dart';

enum AdminOrderStatusFilter {
  all('Tất cả'),
  pending('Chờ duyệt'),
  approved('Đã duyệt'),
  shipping('Đang giao'),
  completed('Hoàn thành'),
  cancelled('Đã hủy / Từ chối');

  const AdminOrderStatusFilter(this.label);
  final String label;

  bool matches(Order order) {
    final status = order.status.toUpperCase().trim();
    switch (this) {
      case AdminOrderStatusFilter.all:
        return true;
      case AdminOrderStatusFilter.pending:
        return status == 'PENDING';
      case AdminOrderStatusFilter.approved:
        return status == 'APPROVED';
      case AdminOrderStatusFilter.shipping:
        return status == 'SHIPPING';
      case AdminOrderStatusFilter.completed:
        return status == 'COMPLETED';
      case AdminOrderStatusFilter.cancelled:
        return status == 'CANCELLED' || status == 'REJECTED';
    }
  }
}

/// Lớp quản lý trạng thái bộ lọc và điều hướng cho AdminOrderListPage (SOLID SRP)
class AdminOrderListLogic extends ChangeNotifier {
  AdminOrderStatusFilter selectedFilter = AdminOrderStatusFilter.all;

  void setFilter(AdminOrderStatusFilter filter) {
    if (selectedFilter != filter) {
      selectedFilter = filter;
      notifyListeners();
    }
  }

  void loadOrders(BuildContext context) {
    context.read<OrderProvider>().loadOrders(isAdmin: true);
  }

  void openDetail(BuildContext context, Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(order: order),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<OrderProvider>().loadOrders(isAdmin: true);
      }
    });
  }

  List<Order> getFilteredOrders(List<Order> allOrders) {
    return allOrders.where(selectedFilter.matches).toList();
  }
}
