import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.order});

  final Order order;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<Order> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // Danh sách đã kèm chi tiết thì dùng luôn, không gọi thêm API.
  Future<Order> _load() {
    if (widget.order.items.isNotEmpty) return Future.value(widget.order);
    return context.read<OrderProvider>().fetchOrder(widget.order.id);
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đơn #${widget.order.id}')),
      body: FutureBuilder<Order>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is AppException
                ? error.message
                : 'Không tải được chi tiết đơn hàng';
            return _ErrorView(message: message, onRetry: _retry);
          }
          return _OrderDetailBody(order: snapshot.data!);
        },
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final books = context.watch<BookProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ngày đặt: ${DateFormatter.dateTime(order.date)}'),
        const SizedBox(height: 4),
        Text(
          'Trạng thái: ${order.status}',
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        const Divider(height: 32),
        Text('Sản phẩm', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in order.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(books.bookNameOf(item.bookId) ?? 'Sách #${item.bookId}'),
            subtitle: Text(
              '${CurrencyFormatter.vnd(item.price)} × ${item.quantity}',
            ),
            trailing: Text(CurrencyFormatter.vnd(item.subtotal)),
          ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tổng cộng', style: theme.textTheme.titleMedium),
            Text(
              CurrencyFormatter.vnd(order.totalPrice),
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
