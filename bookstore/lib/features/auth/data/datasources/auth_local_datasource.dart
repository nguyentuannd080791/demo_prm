import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final SharedPreferences _prefs;

  Future<String?> readToken() async {
    final token = _prefs.getString(_tokenKey);
    if (token == null || token.trim().isEmpty) return null;
    return token.trim();
  }

  UserModel? readUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool get hasSession {
    final token = _prefs.getString(_tokenKey);
    final user = _prefs.getString(_userKey);
    return token != null && token.isNotEmpty && user != null && user.isNotEmpty;
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
