import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final SharedPreferences _prefs;

  Future<String?> readToken() async => _prefs.getString(_tokenKey);

  UserModel? readUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSession(String token, UserModel user) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
