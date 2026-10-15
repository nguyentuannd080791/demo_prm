import 'package:flutter/foundation.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._repository);

  final CartRepository _repository;

  Cart _cart = const Cart();

  Cart get cart => _cart;
  int get totalQuantity => _cart.totalQuantity;

  /// Gọi lại sau mỗi lần đăng nhập vì giỏ hàng theo từng tài khoản.
  Future<void> load() async {
    try {
      _cart = await _repository.getCart();
    } catch (_) {
      _cart = const Cart(); // dữ liệu lưu bị hỏng -> bắt đầu giỏ mới
    }
    notifyListeners();
  }

  Future<void> add(CartItem item) => _update(_cart.add(item));

  Future<void> changeQuantity(int bookId, int quantity) =>
      _update(_cart.changeQuantity(bookId, quantity));

  Future<void> remove(int bookId) => _update(_cart.remove(bookId));

  Future<void> clear() => _update(const Cart());

  Future<void> _update(Cart next) async {
    _cart = next;
    notifyListeners();
    await _repository.saveCart(next);
  }
}
