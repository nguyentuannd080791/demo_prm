import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/order.dart';
import '../pages/order_detail_page.dart';
import '../providers/order_provider.dart';

enum OrderStatusFilter {
  all('Tất cả'),
  pending('Chờ duyệt'),
  shipping('Đang giao'),
  completed('Hoàn thành'),
  cancelled('Đã hủy');

  const OrderStatusFilter(this.label);
  final String label;

  bool matches(Order order) {
    final status = order.status.toUpperCase().trim();
    switch (this) {
      case OrderStatusFilter.all:
        return true;
      case OrderStatusFilter.pending:
        return status == 'PENDING';
      case OrderStatusFilter.shipping:
        return status == 'APPROVED' || status == 'SHIPPING';
      case OrderStatusFilter.completed:
        return status == 'COMPLETED';
      case OrderStatusFilter.cancelled:
        return status == 'CANCELLED' || status == 'REJECTED';
    }
  }
}

/// Lớp quản lý trạng thái bộ lọc và điều hướng cho OrderListPage của khách hàng (SOLID SRP)
class OrderListLogic extends ChangeNotifier {
  OrderStatusFilter selectedFilter = OrderStatusFilter.all;

  void setFilter(OrderStatusFilter filter) {
    if (selectedFilter != filter) {
      selectedFilter = filter;
      notifyListeners();
    }
  }

  void loadOrders(BuildContext context) {
    context.read<OrderProvider>().loadOrders();
  }

  void openDetail(BuildContext context, Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrderDetailPage(order: order)),
    );
  }

  List<Order> getFilteredOrders(List<Order> allOrders) {
    return allOrders.where(selectedFilter.matches).toList();
  }
}
