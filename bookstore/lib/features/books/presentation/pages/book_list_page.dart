import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/book_filter_sheet.dart';
import 'add_book_page.dart';
import 'book_detail_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
        context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDetail(Book book) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailPage(book: book)),
    );
    if (mounted) {
      final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
      context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
    }
  }

  void _openFilterSheet(
    BuildContext context, {
    required bool isAdmin,
    required List<String> availableTags,
  }) {
    final provider = context.read<BookProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BookFilterSheet(
        currentParams: provider.filterParams,
        isAdmin: isAdmin,
        availableTags: availableTags,
        onApply: (params) {
          provider.applyFilters(params, isAdmin: isAdmin);
        },
        onReset: () {
          provider.resetFilters(isAdmin: isAdmin);
          _searchController.clear();
        },
      ),
    );
  }

  void _handleSearchSubmit(String keyword, {required bool isAdmin}) {
    final provider = context.read<BookProvider>();
    final trimmed = keyword.trim();
    provider.applyFilters(
      provider.filterParams.copyWith(
        keyword: trimmed,
        clearKeyword: trimmed.isEmpty,
      ),
      isAdmin: isAdmin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.isAdmin ?? false;
    final theme = Theme.of(context);
    final filterParams = provider.filterParams;
    final activeTag = filterParams.tag ?? 'Tất cả';

    if (provider.isLoading && provider.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.books.isEmpty) {
      return _ErrorView(
        message: provider.error!,
        onRetry: () => provider.loadBooks(isAdmin: isAdmin),
      );
    }

    // Trích xuất toàn bộ tags duy nhất từ danh sách sách hiện có
    final Set<String> tagSet = {};
    for (final b in provider.books) {
      tagSet.addAll(b.tags);
    }
    final availableTags = ['Tất cả', ...tagSet];

    // Lọc sách theo:
    // 1. Phân quyền: Người dùng bình thường không bao giờ thấy sách hết hàng (!b.status)
    // 2. Thể loại/Chủ đề: filterParams.tag
    final filteredBooks = provider.books.where((b) {
      if (!isAdmin && (!b.status || b.stockQuantity <= 0)) {
        return false;
      }
      if (activeTag != 'Tất cả' && !b.tags.contains(activeTag)) {
        return false;
      }
      return true;
    }).toList();

    // Kiểm tra xem có bộ lọc nào đang được kích hoạt hay không
    final hasActiveKeyword =
        filterParams.keyword != null && filterParams.keyword!.trim().isNotEmpty;
    final hasActiveTag = activeTag != 'Tất cả';
    final hasActivePrice =
        filterParams.minPrice != null || filterParams.maxPrice != null;
    final hasActiveStatus =
        isAdmin &&
        filterParams.status != null &&
        filterParams.status!.isNotEmpty &&
        filterParams.status != 'ALL';

    final hasAnyFilter =
        hasActiveKeyword || hasActiveTag || hasActivePrice || hasActiveStatus;

    return Column(
      children: [
        // Thanh tìm kiếm tích hợp nút Bộ lọc ở góc phải
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Tìm kiếm sách, tác giả, NXB...',
            leading: const Icon(Icons.search),
            onSubmitted: (text) => _handleSearchSubmit(text, isAdmin: isAdmin),
            trailing: [
              if (_searchController.text.isNotEmpty || hasActiveKeyword)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    _searchController.clear();
                    _handleSearchSubmit('', isAdmin: isAdmin);
                  },
                ),
              IconButton(
                icon: Badge(
                  isLabelVisible: filterParams.hasAdvancedFilters || hasActiveTag,
                  smallSize: 8,
                  child: Icon(
                    Icons.tune,
                    color:
                        (filterParams.hasAdvancedFilters || hasActiveTag)
                            ? theme.colorScheme.primary
                            : null,
                  ),
                ),
                tooltip: 'Bộ lọc',
                onPressed: () => _openFilterSheet(
                  context,
                  isAdmin: isAdmin,
                  availableTags: availableTags,
                ),
              ),
            ],
            elevation: const WidgetStatePropertyAll(1),
          ),
        ),

        // Thanh chip các tiêu chí đang lọc (Chỉ hiển thị khi có bộ lọc hoạt động)
        if (hasAnyFilter)
          Container(
            height: 36,
            margin: const EdgeInsets.only(top: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Chip Từ khóa
                if (hasActiveKeyword) ...[
                  InputChip(
                    avatar: const Icon(Icons.search, size: 15),
                    label: Text('Từ khóa: "${filterParams.keyword}"'),
                    onDeleted: () {
                      _searchController.clear();
                      provider.applyFilters(
                        filterParams.copyWith(clearKeyword: true),
                        isAdmin: isAdmin,
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                ],

                // Chip Chủ đề / Tag
                if (hasActiveTag) ...[
                  InputChip(
                    avatar: const Icon(Icons.tag, size: 15),
                    label: Text(activeTag),
                    onDeleted: () {
                      provider.applyFilters(
                        filterParams.copyWith(clearTag: true),
                        isAdmin: isAdmin,
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                ],

                // Chip Khoảng giá
                if (hasActivePrice) ...[
                  InputChip(
                    avatar: const Icon(Icons.attach_money, size: 15),
                    label: Text(
                      filterParams.minPrice != null &&
                              filterParams.maxPrice != null
                          ? '${CurrencyFormatter.vnd(filterParams.minPrice!)} - ${CurrencyFormatter.vnd(filterParams.maxPrice!)}'
                          : filterParams.minPrice != null
                              ? 'Từ ${CurrencyFormatter.vnd(filterParams.minPrice!)}'
                              : 'Đến ${CurrencyFormatter.vnd(filterParams.maxPrice!)}',
                    ),
                    onDeleted: () {
                      provider.applyFilters(
                        filterParams.copyWith(
                          clearMinPrice: true,
                          clearMaxPrice: true,
                        ),
                        isAdmin: isAdmin,
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                ],

                // Chip Trạng thái (Chỉ hiển thị cho Admin khi lọc trạng thái)
                if (hasActiveStatus) ...[
                  InputChip(
                    avatar: Icon(
                      filterParams.status == 'ACTIVE'
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      size: 15,
                      color: filterParams.status == 'ACTIVE'
                          ? Colors.green
                          : Colors.grey.shade700,
                    ),
                    label: Text(
                      filterParams.status == 'ACTIVE'
                          ? 'Đang mở bán'
                          : 'Dừng bán',
                    ),
                    onDeleted: () {
                      provider.applyFilters(
                        filterParams.copyWith(clearStatus: true),
                        isAdmin: isAdmin,
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                ],

                // Nút Xóa tất cả bộ lọc
                ActionChip(
                  avatar: const Icon(Icons.close, size: 14),
                  label: const Text('Xóa tất cả lọc'),
                  onPressed: () {
                    _searchController.clear();
                    provider.resetFilters(isAdmin: isAdmin);
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

        // Dòng hiển thị số lượng sách thanh thoát, gọn gàng
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredBooks.length} cuốn sách',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasAnyFilter)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    provider.resetFilters(isAdmin: isAdmin);
                  },
                  child: Text(
                    'Đặt lại bộ lọc',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Danh sách sách hiển thị
        Expanded(
          child: filteredBooks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hasAnyFilter
                              ? 'Không tìm thấy sách phù hợp với bộ lọc hiện tại'
                              : 'Chưa có cuốn sách nào trong hệ thống',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (hasAnyFilter) ...[
                          OutlinedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              provider.resetFilters(isAdmin: isAdmin);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Đặt lại bộ lọc'),
                          ),
                        ] else if (isAdmin) ...[
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AddBookPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm cuốn sách đầu tiên'),
                          ),
                        ] else ...[
                          OutlinedButton.icon(
                            onPressed: () => provider.loadBooks(isAdmin: isAdmin),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tải lại danh sách'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadBooks(isAdmin: isAdmin),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredBooks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final book = filteredBooks[index];
                      return BookCard(
                        book: book,
                        onTap: () => _openDetail(book),
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
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
