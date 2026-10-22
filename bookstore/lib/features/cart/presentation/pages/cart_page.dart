import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../logic/cart_logic.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

/// Màn hình giỏ hàng (Pure UI - SOLID SRP)
/// Logic kiểm tra tồn kho & thao tác giỏ hàng được xử lý bởi [CartLogic].
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_shopping_cart_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Giỏ hàng của bạn đang trống',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy tìm và chọn thêm những cuốn sách hay vào giỏ hàng nhé!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final books = context.watch<BookProvider>().books;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final stock = CartLogic.getBookStock(books, item.bookId);

              return CartItemTile(
                item: item,
                maxStock: stock,
                onIncrease: () =>
                    CartLogic.handleIncreaseItem(context, item, stock),
                onDecrease: () =>
                    CartLogic.handleDecreaseItem(context, item.bookId, item.quantity),
                onRemove: () =>
                    CartLogic.handleRemoveItem(context, item.bookId),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tổng cộng (${cart.totalQuantity} cuốn)',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        CurrencyFormatter.vnd(cart.totalPrice),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => CartLogic.navigateToCheckout(context),
                  icon: const Icon(Icons.payment),
                  label: const Text('Đặt hàng'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
