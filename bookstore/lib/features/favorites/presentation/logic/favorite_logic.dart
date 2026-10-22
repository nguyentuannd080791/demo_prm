import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../providers/favorite_provider.dart';

/// Lớp điều phối logic cho FavoritePage (SOLID SRP)
class FavoriteLogic {
  const FavoriteLogic._();

  static List<Book> getFavoriteBooks(
    List<Book> allBooks,
    FavoriteProvider favoriteProvider,
  ) {
    return allBooks
        .where((book) => favoriteProvider.isFavorite(book.bookId))
        .toList();
  }

  static void openDetail(BuildContext context, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailPage(book: book)),
    );
  }

  static Future<void> refresh(BuildContext context) {
    return Future.wait([
      context.read<BookProvider>().loadBooks(),
      context.read<FavoriteProvider>().load(),
    ]);
  }
}
