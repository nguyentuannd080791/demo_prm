import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../../orders/presentation/pages/checkout_page.dart';
import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';
import 'add_book_page.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.book});

  final Book book;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  int _quantity = 1;

  void _addToCart(Book book, {bool showToast = true}) {
    final cart = context.read<CartProvider>().cart;
    final itemIndex = cart.items.indexWhere((e) => e.bookId == book.bookId);
    final inCart = itemIndex != -1 ? cart.items[itemIndex].quantity : 0;

    if (inCart + _quantity > book.stockQuantity) {
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
        quantity: _quantity,
      ),
    );
    if (showToast) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Đã thêm $_quantity cuốn vào giỏ hàng'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _buyNow(Book book) async {
    _addToCart(book, showToast: false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CheckoutPage()),
    );
    if (mounted) {
      final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
      await context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Book book) async {
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

  void _editBook(BuildContext context, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddBookPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.isAdmin ?? false;

    // Lấy thông tin sách mới nhất từ BookProvider nếu vừa được sửa
    final bookFromProvider = context.select<BookProvider, Book?>(
      (p) => p.books.cast<Book?>().firstWhere(
            (b) => b?.bookId == widget.book.bookId,
            orElse: () => null,
          ),
    );
    final book = bookFromProvider ?? widget.book;

    // Tự động đồng bộ số lượng chọn theo tồn kho thực tế nếu sách vừa bị trừ kho
    if (book.stockQuantity <= 0 && _quantity != 0) {
      _quantity = 0;
    } else if (book.stockQuantity > 0 && _quantity > book.stockQuantity) {
      _quantity = book.stockQuantity;
    } else if (book.stockQuantity > 0 && _quantity == 0) {
      _quantity = 1;
    }

    final isFav = context.select<FavoriteProvider, bool>(
      (fav) => fav.isFavorite(book.bookId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(book.bookName),
        actions: [
          if (!isAdmin)
            IconButton(
              tooltip: isFav ? 'Bỏ yêu thích' : 'Yêu thích',
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : null,
              ),
              onPressed: () =>
                  context.read<FavoriteProvider>().toggleFavorite(book.bookId),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: isAdmin
              // Admin: Các thao tác Quản lý (Sửa, Xóa) - Không thể đặt sách
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _confirmDelete(context, book),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Xóa sách'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _editBook(context, book),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Chỉnh sửa'),
                      ),
                    ),
                  ],
                )
              // Khách hàng: Mua hàng bình thường
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (book.status && book.stockQuantity > 0)
                            ? () => _addToCart(book)
                            : null,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Thêm vào giỏ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: (book.status && book.stockQuantity > 0)
                            ? () => _buyNow(book)
                            : null,
                        icon: Icon(
                          (book.status && book.stockQuantity > 0)
                              ? Icons.shopping_bag_outlined
                              : (!book.status
                                  ? Icons.pause_circle_outline
                                  : Icons.remove_shopping_cart_outlined),
                        ),
                        label: Text(
                          (book.status && book.stockQuantity > 0)
                              ? 'Mua ngay'
                              : (!book.status ? 'Dừng bán' : 'Hết hàng'),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 130,
              height: 180,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            book.bookName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                CurrencyFormatter.vnd(book.price),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) {
                  final String statusText;
                  final Color textColor;
                  final Color bgColor;

                  if (!book.status) {
                    statusText = 'Dừng bán';
                    textColor = Colors.grey.shade800;
                    bgColor = Colors.grey.withValues(alpha: 0.18);
                  } else if (book.stockQuantity <= 0) {
                    statusText = 'Hết hàng';
                    textColor = Colors.red.shade800;
                    bgColor = Colors.red.withValues(alpha: 0.12);
                  } else {
                    statusText = 'Đang bán';
                    textColor = Colors.green.shade800;
                    bgColor = Colors.green.withValues(alpha: 0.12);
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!isAdmin) ...[
            if (book.status && book.stockQuantity > 0) ...[
              // Số lượng cho khách hàng
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số lượng:', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Kho: ${book.stockQuantity} cuốn',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _quantity >= book.stockQuantity
                              ? Colors.orange.shade800
                              : theme.colorScheme.outline,
                          fontWeight: _quantity >= book.stockQuantity
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton.outlined(
                    iconSize: 18,
                    tooltip: 'Giảm số lượng',
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.outlined(
                    iconSize: 18,
                    tooltip: _quantity >= book.stockQuantity
                        ? 'Đã đạt giới hạn tồn kho (${book.stockQuantity})'
                        : 'Thêm số lượng',
                    onPressed: _quantity < book.stockQuantity
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const Divider(height: 24),
            ] else ...[
              Row(
                children: [
                  Text(
                    'Số lượng:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const Spacer(),
                  const IconButton.outlined(
                    iconSize: 18,
                    onPressed: null,
                    icon: Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '0',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  const IconButton.outlined(
                    iconSize: 18,
                    onPressed: null,
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: !book.status
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: !book.status
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      !book.status
                          ? Icons.pause_circle_outline
                          : Icons.warning_amber_rounded,
                      color: !book.status
                          ? Colors.grey.shade700
                          : Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        !book.status
                            ? 'Sản phẩm hiện đang tạm dừng bán'
                            : 'Sản phẩm hiện đang tạm hết hàng',
                        style: TextStyle(
                          color: !book.status
                              ? Colors.grey.shade800
                              : Colors.red.shade800,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
            ],
          ],
          _InfoRow(label: 'Tác giả', value: book.author),
          _InfoRow(label: 'Nhà xuất bản', value: book.publisher),
          _InfoRow(label: 'Số lượng tồn kho', value: '${book.stockQuantity} cuốn'),
          const Divider(height: 32),
          Text(
            'Tóm tắt nội dung',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.summary.isEmpty
                ? 'Chưa có thông tin tóm tắt cho cuốn sách này.'
                : book.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Chưa cập nhật' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
