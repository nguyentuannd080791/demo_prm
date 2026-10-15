import 'package:flutter/foundation.dart';

import '../../domain/repositories/favorite_repository.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider(this._repository);

  final FavoriteRepository _repository;

  Set<int> _favoriteIds = <int>{};
  bool _isLoading = false;

  Set<int> get favoriteIds => _favoriteIds;
  int get count => _favoriteIds.length;
  bool get isLoading => _isLoading;

  bool isFavorite(int bookId) => _favoriteIds.contains(bookId);

  Future<void> load() async {
    _isLoading = true;
    try {
      _favoriteIds = await _repository.getFavoriteBookIds();
    } catch (_) {
      _favoriteIds = <int>{};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int bookId) async {
    final next = Set<int>.from(_favoriteIds);
    if (next.contains(bookId)) {
      next.remove(bookId);
    } else {
      next.add(bookId);
    }
    _favoriteIds = next;
    notifyListeners();
    await _repository.saveFavoriteBookIds(_favoriteIds);
  }

  Future<void> clear() async {
    _favoriteIds = <int>{};
    notifyListeners();
    await _repository.saveFavoriteBookIds(_favoriteIds);
  }
}
