import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../orders/presentation/pages/checkout_page.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';

/// Lớp điều phối logic nghiệp vụ cho CartPage (SOLID SRP)
/// Quản lý kiểm tra tồn kho, cảnh báo điều chỉnh giỏ và chuyển sang Checkout.
class CartLogic {
  const CartLogic._();

  /// Lấy tồn kho của sách từ danh sách sách
  static int? getBookStock(List<Book> books, int bookId) {
    final book = books.cast<Book?>().firstWhere(
          (b) => b?.bookId == bookId,
          orElse: () => null,
        );
    return book?.stockQuantity;
  }

  /// Tăng số lượng sản phẩm có kiểm tra tồn kho
  static void handleIncreaseItem(BuildContext context, CartItem item, int? stock) {
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
    context.read<CartProvider>().changeQuantity(item.bookId, item.quantity + 1);
  }

  /// Giảm số lượng sản phẩm
  static void handleDecreaseItem(BuildContext context, int bookId, int currentQuantity) {
    context.read<CartProvider>().changeQuantity(bookId, currentQuantity - 1);
  }

  /// Xóa sản phẩm khỏi giỏ
  static void handleRemoveItem(BuildContext context, int bookId) {
    context.read<CartProvider>().remove(bookId);
  }

  /// Kiểm tra tồn kho trước khi chuyển sang Checkout
  static Future<void> navigateToCheckout(BuildContext context) async {
    final bookProvider = context.read<BookProvider>();
    final cartProvider = context.read<CartProvider>();
    final books = bookProvider.books;

    final adjustments = <String>[];
    for (final item in List.of(cartProvider.cart.items)) {
      final book = books.cast<Book?>().firstWhere(
            (b) => b?.bookId == item.bookId,
            orElse: () => null,
          );

      if (book == null || !book.status || book.stockQuantity <= 0) {
        await cartProvider.remove(item.bookId);
        final reason = (book != null && !book.status)
            ? 'tạm dừng bán'
            : 'đã hết hàng';
        adjustments.add('Sách "${item.bookName}" hiện $reason nên đã được xóa khỏi giỏ.');
      } else if (item.quantity > book.stockQuantity) {
        await cartProvider.changeQuantity(item.bookId, book.stockQuantity);
        adjustments.add(
          'Sách "${item.bookName}" chỉ còn ${book.stockQuantity} cuốn trong kho. Đã điều chỉnh về ${book.stockQuantity} cuốn.',
        );
      }
    }

    if (adjustments.isNotEmpty && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.info_outline, color: Colors.orange, size: 44),
          title: const Text('Cập nhật giỏ hàng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Số lượng sách trong giỏ có sự thay đổi theo tồn kho thực tế:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                for (final msg in adjustments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(msg, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Xem lại giỏ hàng'),
            ),
          ],
        ),
      );
      return;
    }

    if (cartProvider.cart.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Giỏ hàng trống hoặc các sản phẩm đều không còn mở bán.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CheckoutPage()),
    );
  }
}
