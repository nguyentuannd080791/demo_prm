import 'package:shared_preferences/shared_preferences.dart';

/// Lưu danh sách bookId yêu thích của từng tài khoản theo khóa: `favorites_<username>`.
class FavoritePrefsDataSource {
  FavoritePrefsDataSource(this._prefs, this._readUsername);

  final SharedPreferences _prefs;
  final String? Function() _readUsername;

  String get _key => 'favorites_${_readUsername() ?? 'guest'}';

  Set<int> read() {
    final raw = _prefs.getStringList(_key);
    if (raw == null) return <int>{};
    return raw.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  Future<void> write(Set<int> ids) {
    final list = ids.map((id) => id.toString()).toList();
    return _prefs.setStringList(_key, list);
  }
}
