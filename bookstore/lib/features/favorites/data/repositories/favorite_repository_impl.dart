import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_prefs_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl(this._dataSource);

  final FavoritePrefsDataSource _dataSource;

  @override
  Future<Set<int>> getFavoriteBookIds() async {
    return _dataSource.read();
  }

  @override
  Future<void> saveFavoriteBookIds(Set<int> bookIds) async {
    await _dataSource.write(bookIds);
  }
}
