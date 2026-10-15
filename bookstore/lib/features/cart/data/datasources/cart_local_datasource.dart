import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';

/// Mỗi tài khoản một giỏ riêng trên máy: khóa `cart_<username>`.
class CartLocalDataSource {
  CartLocalDataSource(this._prefs, this._readUsername);

  final SharedPreferences _prefs;
  final String? Function() _readUsername;

  String get _key => 'cart_${_readUsername() ?? 'guest'}';

  List<CartItemModel> read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> write(List<CartItemModel> items) {
    return _prefs.setString(
      _key,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
