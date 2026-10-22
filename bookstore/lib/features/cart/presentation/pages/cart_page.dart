import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../orders/presentation/pages/checkout_page.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

/// Chỉ là phần thân; AppBar do HomeShell cung cấp.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _navigateToCheckout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CheckoutPage()),
    );
  }

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
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final books = context.watch<BookProvider>().books;
              final book = books.cast<Book?>().firstWhere(
                    (b) => b?.bookId == item.bookId,
                    orElse: () => null,
                  );
              final stock = book?.stockQuantity;

              return CartItemTile(
                item: item,
                maxStock: stock,
                onIncrease: () {
                  if (stock != null && item.quantity >= stock) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Sách "${item.bookName}" chỉ còn $stock cuốn trong kho',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    return;
                  }
                  cartProvider.changeQuantity(item.bookId, item.quantity + 1);
                },
                onDecrease: () =>
                    cartProvider.changeQuantity(item.bookId, item.quantity - 1),
                onRemove: () => cartProvider.remove(item.bookId),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng cộng (${cart.totalQuantity} cuốn):',
                    style: theme.textTheme.titleMedium,
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
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _navigateToCheckout(context),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Tiến hành đặt hàng',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
