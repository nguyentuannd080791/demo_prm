import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book.dart';
import '../pages/book_detail_page.dart';
import '../providers/book_provider.dart';
import '../widgets/book_filter_sheet.dart';

/// Lớp điều phối logic cho BookListPage (SOLID SRP)
/// Quản lý controller tìm kiếm, lọc tags, phân quyền hiển thị và điều hướng.
class BookListLogic extends ChangeNotifier {
  final searchController = TextEditingController();

  void loadBooks(BuildContext context) {
    final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
    context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
  }

  Future<void> openDetail(BuildContext context, Book book) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailPage(book: book)),
    );
    if (context.mounted) {
      final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
      context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
    }
  }

  void openFilterSheet(
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
          searchController.clear();
        },
      ),
    );
  }

  void handleSearchSubmit(BuildContext context, String keyword, {required bool isAdmin}) {
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

  List<String> extractAvailableTags(List<Book> books) {
    final Set<String> tagSet = {};
    for (final b in books) {
      tagSet.addAll(b.tags);
    }
    return ['Tất cả', ...tagSet];
  }

  List<Book> filterBooks(
    List<Book> books, {
    required bool isAdmin,
    String? activeTag,
  }) {
    return books.where((b) {
      if (!isAdmin && (!b.status || b.stockQuantity <= 0)) {
        return false;
      }
      if (activeTag != null && activeTag != 'Tất cả' && !b.tags.contains(activeTag)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
