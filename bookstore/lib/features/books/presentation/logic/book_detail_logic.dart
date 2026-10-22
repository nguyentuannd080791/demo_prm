import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../../orders/presentation/pages/checkout_page.dart';
import '../../domain/entities/book.dart';
import '../pages/add_book_page.dart';
import '../providers/book_provider.dart';

/// Lớp điều phối logic nghiệp vụ cho BookDetailPage (SOLID SRP)
/// Quản lý số lượng chọn mua, thêm giỏ hàng, mua ngay, chỉnh sửa, xóa và toggle yêu thích.
class BookDetailLogic extends ChangeNotifier {
  int quantity = 1;

  void syncQuantityWithStock(int stockQuantity) {
    if (stockQuantity <= 0 && quantity != 0) {
      quantity = 0;
      notifyListeners();
    } else if (stockQuantity > 0 && quantity > stockQuantity) {
      quantity = stockQuantity;
      notifyListeners();
    } else if (stockQuantity > 0 && quantity == 0) {
      quantity = 1;
      notifyListeners();
    }
  }

  void incrementQuantity(Book book) {
    if (quantity < book.stockQuantity) {
      quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  void addToCart(BuildContext context, Book book, {bool showToast = true}) {
    final cart = context.read<CartProvider>().cart;
    final itemIndex = cart.items.indexWhere((e) => e.bookId == book.bookId);
    final inCart = itemIndex != -1 ? cart.items[itemIndex].quantity : 0;

    if (inCart + quantity > book.stockQuantity) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              inCart > 0
                  ? 'Giỏ hàng đã có $inCart cuốn. Tồn kho chỉ còn ${book.stockQuantity} cuốn.'
                  : 'Không thể mua quá số lượng tồn kho (${book.stockQuantity} cuốn).',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    context.read<CartProvider>().add(
          CartItem(
            bookId: book.bookId,
            bookName: book.bookName,
            price: book.price,
            quantity: quantity,
          ),
        );

    if (showToast) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Đã thêm $quantity cuốn vào giỏ hàng'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> buyNow(BuildContext context, Book book) async {
    addToCart(context, book, showToast: false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CheckoutPage()),
    );
    if (context.mounted) {
      final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
      await context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
    }
  }

  Future<void> openEdit(BuildContext context, Book book) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => AddBookPage(book: book)),
    );
    if (updated == true && context.mounted) {
      final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
      await context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
    }
  }

  Future<void> confirmDelete(BuildContext context, Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa sách'),
        content: Text(
          'Bạn có chắc chắn muốn xóa cuốn sách "${book.bookName}" khỏi hệ thống? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context.read<BookProvider>().deleteBook(book.bookId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa thành công sách "${book.bookName}"'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa sách thất bại: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void toggleFavorite(BuildContext context, int bookId) {
    context.read<FavoriteProvider>().toggleFavorite(bookId);
  }
}
