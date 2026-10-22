import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/shipping_address.dart';

/// Quản lý danh sách địa chỉ giao hàng của người dùng tại Local Storage (SharedPreferences)
/// Tuân thủ Single Responsibility Principle (SRP)
class AddressLocalDataSource {
  const AddressLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  String _keyFor(int userId) => 'user_addresses_$userId';

  List<ShippingAddress> getAddresses(int userId) {
    final raw = _prefs.getString(_keyFor(userId));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ShippingAddress.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  ShippingAddress? getDefaultOrFirst(int userId) {
    final list = getAddresses(userId);
    if (list.isEmpty) return null;
    return list.firstWhere(
      (a) => a.isDefault,
      orElse: () => list.first,
    );
  }

  Future<void> saveAddress(int userId, ShippingAddress address) async {
    final list = getAddresses(userId).toList();
    final index = list.indexWhere((a) => a.id == address.id);

    // Nếu địa chỉ này được đặt làm mặc định hoặc là địa chỉ đầu tiên, bỏ default các địa chỉ cũ
    final makeDefault = address.isDefault || list.isEmpty;

    List<ShippingAddress> updatedList = list.map((a) {
      if (makeDefault) {
        return a.copyWith(isDefault: false);
      }
      return a;
    }).toList();

    final addressToSave = address.copyWith(isDefault: makeDefault);

    if (index >= 0) {
      updatedList[index] = addressToSave;
    } else {
      updatedList.add(addressToSave);
    }

    await _saveList(userId, updatedList);
  }

  Future<void> deleteAddress(int userId, String addressId) async {
    final list = getAddresses(userId).toList();
    final wasDefault = list.any((a) => a.id == addressId && a.isDefault);
    list.removeWhere((a) => a.id == addressId);

    // Nếu vừa xóa địa chỉ mặc định và danh sách còn phần tử, đặt phần tử đầu tiên làm mặc định
    if (wasDefault && list.isNotEmpty) {
      list[0] = list[0].copyWith(isDefault: true);
    }

    await _saveList(userId, list);
  }

  Future<void> setDefaultAddress(int userId, String addressId) async {
    final list = getAddresses(userId).map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();
    await _saveList(userId, list);
  }

  Future<void> _saveList(int userId, List<ShippingAddress> list) async {
    final raw = jsonEncode(list.map((a) => a.toJson()).toList());
    await _prefs.setString(_keyFor(userId), raw);
  }
}
