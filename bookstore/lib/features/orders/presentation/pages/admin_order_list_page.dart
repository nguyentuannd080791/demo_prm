import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';
import 'order_detail_page.dart';

enum _AdminOrderStatusFilter {
  all('Tất cả'),
  pending('Chờ duyệt'),
  approved('Đã duyệt'),
  shipping('Đang giao'),
  completed('Hoàn thành'),
  cancelled('Đã hủy / Từ chối');

  const _AdminOrderStatusFilter(this.label);
  final String label;

  bool matches(Order order) {
    final status = order.status.toUpperCase().trim();
    switch (this) {
      case _AdminOrderStatusFilter.all:
        return true;
      case _AdminOrderStatusFilter.pending:
        return status == 'PENDING';
      case _AdminOrderStatusFilter.approved:
        return status == 'APPROVED';
      case _AdminOrderStatusFilter.shipping:
        return status == 'SHIPPING';
      case _AdminOrderStatusFilter.completed:
        return status == 'COMPLETED';
      case _AdminOrderStatusFilter.cancelled:
        return status == 'CANCELLED' || status == 'REJECTED';
    }
  }
}

class AdminOrderListPage extends StatefulWidget {
  const AdminOrderListPage({super.key});

  @override
  State<AdminOrderListPage> createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
  _AdminOrderStatusFilter _selectedFilter = _AdminOrderStatusFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderProvider>().loadOrders(isAdmin: true);
      }
    });
  }

  void _openDetail(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(order: order),
      ),
    ).then((_) {
      if (mounted) {
        context.read<OrderProvider>().loadOrders(isAdmin: true);
      }
    });
  }

  Future<void> _handleApprove(BuildContext context, Order order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Phê duyệt đơn hàng'),
        content: Text(
          'Xác nhận phê duyệt đơn hàng #${order.id} của khách hàng ${order.receiverName.isNotEmpty ? order.receiverName : 'Người dùng'}?',
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
      }
    }
  }

  Future<void> _handleReject(BuildContext context, Order order) async {
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
      }
    }
  }

  Future<void> _handleShip(BuildContext context, Order order) async {
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
      }
    }
  }

  Future<void> _handleComplete(BuildContext context, Order order) async {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<OrderProvider>();

    if (provider.isLoading && provider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => provider.loadOrders(isAdmin: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final allOrders = provider.orders;
    final filteredOrders = allOrders.where(_selectedFilter.matches).toList();

    return Column(
      children: [
        // Thanh bộ lọc trạng thái
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _AdminOrderStatusFilter.values.map((filter) {
                final isSelected = filter == _selectedFilter;
                final count = allOrders.where(filter.matches).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      count > 0 ? '${filter.label} ($count)' : filter.label,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    selectedColor: theme.colorScheme.primaryContainer,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Danh sách đơn hàng
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadOrders(isAdmin: true),
            child: filteredOrders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 56,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedFilter == _AdminOrderStatusFilter.all
                                    ? 'Chưa có đơn hàng nào trong hệ thống'
                                    : 'Không có đơn hàng nào ở trạng thái "${_selectedFilter.label}"',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final status = order.status.toUpperCase().trim();

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _openDetail(order),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: ID + User + Status
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.receipt_long_rounded,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Đơn #${order.id}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (order.userId != null) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme.surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'User #${order.userId}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme
                                                    .colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    OrderStatusBadge(status: order.status),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Người nhận + SĐT
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 15,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        [
                                          if (order.receiverName.isNotEmpty)
                                            order.receiverName,
                                          if (order.phone.isNotEmpty)
                                            order.phone,
                                        ].join(' • '),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Địa chỉ
                                if (order.shippingAddress.isNotEmpty)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 15,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          order.shippingAddress,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 6),

                                // Thời gian đặt
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 15,
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormatter.dateTime(order.date),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 20),

                                // Bottom: Tổng tiền + Các nút Admin Action
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tổng cộng',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.vnd(
                                            order.totalPrice,
                                          ),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Các action buttons tùy trạng thái
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (status == 'PENDING') ...[
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.red.shade700,
                                              side: BorderSide(
                                                color: Colors.red.shade300,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: () =>
                                                _handleReject(context, order),
                                            child: const Text('Từ chối'),
                                          ),
                                          const SizedBox(width: 8),
                                          FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade700,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: () =>
                                                _handleApprove(context, order),
                                            child: const Text('Duyệt'),
                                          ),
                                        ] else if (status == 'APPROVED') ...[
                                          FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade700,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            icon: const Icon(
                                              Icons.local_shipping_outlined,
                                              size: 16,
                                            ),
                                            label: const Text('Giao hàng'),
                                            onPressed: () =>
                                                _handleShip(context, order),
                                          ),
                                        ] else if (status == 'SHIPPING') ...[
                                          FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade700,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 16,
                                            ),
                                            label: const Text('Hoàn thành'),
                                            onPressed: () =>
                                                _handleComplete(context, order),
                                          ),
                                        ] else ...[
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
