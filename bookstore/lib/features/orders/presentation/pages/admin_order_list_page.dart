import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../logic/admin_order_list_logic.dart';
import '../logic/order_action_logic.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';

/// Màn hình danh sách đơn hàng cho Admin/Staff (Pure UI - SOLID SRP)
/// Quản lý bộ lọc & điều hướng do [AdminOrderListLogic] đảm nhận,
/// các thao tác duyệt/từ chối/giao hàng do [OrderActionLogic] phụ trách.
class AdminOrderListPage extends StatefulWidget {
  const AdminOrderListPage({super.key});

  @override
  State<AdminOrderListPage> createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
  late final AdminOrderListLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = AdminOrderListLogic();
    _logic.addListener(_onLogicChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logic.loadOrders(context);
      }
    });
  }

  void _onLogicChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    super.dispose();
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
                onPressed: () => _logic.loadOrders(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final allOrders = provider.orders;
    final filteredOrders = _logic.getFilteredOrders(allOrders);

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
              children: AdminOrderStatusFilter.values.map((filter) {
                final isSelected = filter == _logic.selectedFilter;
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
                        _logic.setFilter(filter);
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
                                _logic.selectedFilter == AdminOrderStatusFilter.all
                                    ? 'Chưa có đơn hàng nào trong hệ thống'
                                    : 'Không có đơn hàng nào ở trạng thái "${_logic.selectedFilter.label}"',
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
                          onTap: () => _logic.openDetail(context, order),
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
                                                OrderActionLogic.handleReject(
                                              context,
                                              order,
                                              onSuccess: () =>
                                                  _logic.loadOrders(context),
                                            ),
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
                                                OrderActionLogic.handleApprove(
                                              context,
                                              order,
                                              onSuccess: () =>
                                                  _logic.loadOrders(context),
                                            ),
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
                                                OrderActionLogic.handleShip(
                                              context,
                                              order,
                                              onSuccess: () =>
                                                  _logic.loadOrders(context),
                                            ),
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
                                                OrderActionLogic.handleComplete(
                                              context,
                                              order,
                                              onSuccess: () =>
                                                  _logic.loadOrders(context),
                                            ),
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
