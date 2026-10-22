import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../logic/book_list_logic.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_page.dart';

/// Màn hình danh sách sách (Pure UI - SOLID SRP)
/// Quản lý controller tìm kiếm, lọc tags và điều hướng được ủy quyền cho [BookListLogic].
class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late final BookListLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = BookListLogic();
    _logic.addListener(_onLogicChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logic.loadBooks(context);
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
        onRetry: () => _logic.loadBooks(context),
      );
    }

    final availableTags = _logic.extractAvailableTags(provider.books);
    final filteredBooks = _logic.filterBooks(
      provider.books,
      isAdmin: isAdmin,
      activeTag: activeTag,
    );

    final hasActiveKeyword =
        filterParams.keyword != null && filterParams.keyword!.trim().isNotEmpty;
    final hasActiveTag = filterParams.tag != null &&
        filterParams.tag!.isNotEmpty &&
        filterParams.tag != 'Tất cả';
    final hasActivePrice =
        (filterParams.minPrice != null && filterParams.minPrice! > 0) ||
        (filterParams.maxPrice != null && filterParams.maxPrice! > 0);
    final hasActiveStatus =
        isAdmin && filterParams.status != null && filterParams.status != 'ALL';
    final hasAnyFilter = hasActiveKeyword ||
        hasActiveTag ||
        hasActivePrice ||
        hasActiveStatus;

    return Column(
      children: [
        // Thanh tìm kiếm + Nút bộ lọc nâng cao
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _logic.searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên sách hoặc tác giả...',
                    prefixIcon: const Icon(Icons.search, size: 22),
                    suffixIcon: _logic.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _logic.searchController.clear();
                              _logic.handleSearchSubmit(
                                context,
                                '',
                                isAdmin: isAdmin,
                              );
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (kw) => _logic.handleSearchSubmit(
                    context,
                    kw,
                    isAdmin: isAdmin,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: hasAnyFilter,
                child: IconButton.filledTonal(
                  tooltip: 'Bộ lọc nâng cao',
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () => _logic.openFilterSheet(
                    context,
                    isAdmin: isAdmin,
                    availableTags: availableTags,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Dòng hiển thị số lượng sách và nút đặt lại khi đang lọc
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
                    _logic.searchController.clear();
                    provider.resetFilters(isAdmin: isAdmin);
                  },
                  child: Text(
                    'Đặt lại bộ lọc',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Danh sách sách
        Expanded(
          child: filteredBooks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasAnyFilter
                              ? 'Không tìm thấy sách phù hợp với bộ lọc'
                              : 'Chưa có cuốn sách nào trong kho',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasAnyFilter
                              ? 'Hãy thử điều chỉnh lại từ khóa hoặc xóa bớt tiêu chí lọc.'
                              : (isAdmin
                                  ? 'Bạn có thể bắt đầu bằng việc thêm cuốn sách đầu tiên!'
                                  : 'Vui lòng quay lại sau khi cửa hàng cập nhật thêm sách mới.'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (hasAnyFilter) ...[
                          OutlinedButton.icon(
                            onPressed: () {
                              _logic.searchController.clear();
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
                            onPressed: () => _logic.loadBooks(context),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tải lại danh sách'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _logic.loadBooks(context),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredBooks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final book = filteredBooks[index];
                      return BookCard(
                        book: book,
                        onTap: () => _logic.openDetail(context, book),
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
