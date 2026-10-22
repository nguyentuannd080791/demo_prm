import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../domain/entities/book.dart';
import '../logic/book_detail_logic.dart';
import '../providers/book_provider.dart';

/// Màn hình chi tiết sách (Pure UI - SOLID SRP)
/// Quản lý số lượng, giỏ hàng, mua ngay, chỉnh sửa & xóa được ủy quyền cho [BookDetailLogic].
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.book});

  final Book book;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final BookDetailLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = BookDetailLogic();
    _logic.addListener(_onLogicChanged);
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
    _logic.syncQuantityWithStock(book.stockQuantity);

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
              onPressed: () => _logic.toggleFavorite(context, book.bookId),
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
                        onPressed: () => _logic.confirmDelete(context, book),
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
                        onPressed: () => _logic.openEdit(context, book),
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
                            ? () => _logic.addToCart(context, book)
                            : null,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Thêm vào giỏ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: (book.status && book.stockQuantity > 0)
                            ? () => _logic.buyNow(context, book)
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (book.imageURL != null &&
                        book.imageURL!.trim().isNotEmpty)
                    ? Image.network(
                        book.imageURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                      ),
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
                          color: _logic.quantity >= book.stockQuantity
                              ? Colors.orange.shade800
                              : theme.colorScheme.outline,
                          fontWeight: _logic.quantity >= book.stockQuantity
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
                    onPressed: _logic.quantity > 1
                        ? () => _logic.decrementQuantity()
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${_logic.quantity}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.outlined(
                    iconSize: 18,
                    tooltip: _logic.quantity >= book.stockQuantity
                        ? 'Đã đạt giới hạn tồn kho (${book.stockQuantity})'
                        : 'Thêm số lượng',
                    onPressed: _logic.quantity < book.stockQuantity
                        ? () => _logic.incrementQuantity(book)
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
