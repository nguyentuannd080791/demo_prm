abstract class FavoriteRepository {
  Future<Set<int>> getFavoriteBookIds();
  Future<void> saveFavoriteBookIds(Set<int> bookIds);
}
