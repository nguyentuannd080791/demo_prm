import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books/presentation/providers/book_provider.dart';
import '../../../books/presentation/widgets/book_card.dart';
import '../logic/favorite_logic.dart';
import '../providers/favorite_provider.dart';

/// Màn hình sách yêu thích (Pure UI - SOLID SRP)
/// Quản lý lọc sách yêu thích, làm mới và điều hướng do [FavoriteLogic] đảm nhận.
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();

    final favoriteBooks =
        FavoriteLogic.getFavoriteBooks(bookProvider.books, favoriteProvider);

    if (favoriteBooks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có sách yêu thích',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nhấn vào biểu tượng trái tim trên mỗi cuốn sách để lưu vào danh sách yêu thích của bạn.',
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

    return RefreshIndicator(
      onRefresh: () => FavoriteLogic.refresh(context),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: favoriteBooks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final book = favoriteBooks[index];
          return BookCard(
            book: book,
            onTap: () => FavoriteLogic.openDetail(context, book),
          );
        },
      ),
    );
  }
}
