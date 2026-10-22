import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/order_list_logic.dart';
import '../providers/order_provider.dart';
import '../widgets/order_tile.dart';

/// Màn hình danh sách đơn hàng cho Khách hàng (Pure UI - SOLID SRP)
/// Quản lý bộ lọc & điều hướng do [OrderListLogic] đảm nhận.
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late final OrderListLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = OrderListLogic();
    _logic.addListener(_onLogicChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _logic.loadOrders(context);
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
      return _ErrorView(
        message: provider.error!,
        onRetry: () => _logic.loadOrders(context),
      );
    }

    final allOrders = provider.orders;
    final filteredOrders = _logic.getFilteredOrders(allOrders);

    return Column(
      children: [
        // Thanh bộ lọc trạng thái (Filter Chips)
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
              children: OrderStatusFilter.values.map((filter) {
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
                    checkmarkColor: theme.colorScheme.onPrimaryContainer,
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
            onRefresh: () async => _logic.loadOrders(context),
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
                                Icons.receipt_long_outlined,
                                size: 56,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _logic.selectedFilter == OrderStatusFilter.all
                                    ? 'Chưa có đơn hàng nào'
                                    : 'Không có đơn hàng "${_logic.selectedFilter.label}"',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (_logic.selectedFilter != OrderStatusFilter.all) ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () =>
                                      _logic.setFilter(OrderStatusFilter.all),
                                  child: const Text('Xem tất cả đơn hàng'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final order = filteredOrders[index];
                      return OrderTile(
                        order: order,
                        onTap: () => _logic.openDetail(context, order),
                        onOrderCancelled: () => _logic.loadOrders(context),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
