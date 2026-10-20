import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_page.dart';
import 'book_detail_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTag = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookProvider>().loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailPage(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();

    if (provider.isLoading && provider.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.books.isEmpty) {
      return _ErrorView(message: provider.error!, onRetry: provider.loadBooks);
    }

    // Trích xuất toàn bộ tags duy nhất từ danh sách sách hiện có
    final Set<String> tagSet = {};
    for (final b in provider.books) {
      tagSet.addAll(b.tags);
    }
    final availableTags = ['Tất cả', ...tagSet, 'Đang bán', 'Hết hàng'];

    // Lọc theo từ khóa tìm kiếm và tag được chọn
    final filteredBooks = provider.books.where((b) {
      final matchesQuery = _searchQuery.isEmpty ||
          b.bookName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.publisher.toLowerCase().contains(_searchQuery.toLowerCase());

      final bool matchesTag;
      if (_selectedTag == 'Tất cả') {
        matchesTag = true;
      } else if (_selectedTag == 'Đang bán') {
        matchesTag = b.status;
      } else if (_selectedTag == 'Hết hàng') {
        matchesTag = !b.status;
      } else {
        matchesTag = b.tags.contains(_selectedTag);
      }

      return matchesQuery && matchesTag;
    }).toList();

    final theme = Theme.of(context);

    return Column(
      children: [
        // Thanh tìm kiếm tích hợp nút Lọc gọn gàng ở góc phải
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Tìm kiếm sách, tác giả, NXB...',
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              PopupMenuButton<String>(
                icon: Badge(
                  isLabelVisible: _selectedTag != 'Tất cả',
                  smallSize: 8,
                  child: Icon(
                    Icons.tune,
                    color: _selectedTag != 'Tất cả'
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
                tooltip: 'Lọc theo tag',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (tag) => setState(() => _selectedTag = tag),
                itemBuilder: (context) => [
                  for (final tag in availableTags)
                    PopupMenuItem<String>(
                      value: tag,
                      child: Row(
                        children: [
                          Icon(
                            tag == 'Tất cả'
                                ? Icons.apps
                                : tag == 'Đang bán'
                                    ? Icons.check_circle_outline
                                    : tag == 'Hết hàng'
                                        ? Icons.remove_shopping_cart_outlined
                                        : Icons.tag,
                            size: 18,
                            color: _selectedTag == tag
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontWeight: _selectedTag == tag
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedTag == tag
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                          if (_selectedTag == tag)
                            Icon(
                              Icons.check,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            elevation: const WidgetStatePropertyAll(1),
          ),
        ),

        // Thanh trạng thái bộ lọc gọn gàng (hiển thị chip tag khi có lọc + số lượng sách)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              if (_selectedTag != 'Tất cả') ...[
                InputChip(
                  label: Text(_selectedTag),
                  avatar: Icon(
                    _selectedTag == 'Đang bán'
                        ? Icons.check_circle_outline
                        : _selectedTag == 'Hết hàng'
                            ? Icons.remove_shopping_cart_outlined
                            : Icons.tag,
                    size: 16,
                  ),
                  onDeleted: () => setState(() => _selectedTag = 'Tất cả'),
                  deleteIconColor: theme.colorScheme.outline,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              Text(
                '${filteredBooks.length} cuốn sách',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w500,
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
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy sách phù hợp với "$_searchQuery" trong mục "$_selectedTag"'
                              : 'Chưa có sách nào thuộc tag "$_selectedTag"',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                        ),
                        if (_selectedTag != 'Tất cả') ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _selectedTag = 'Tất cả'),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Xem tất cả sách'),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
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
                        ],
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: provider.loadBooks,
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
