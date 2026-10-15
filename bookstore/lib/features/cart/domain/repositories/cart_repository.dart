import '../entities/cart.dart';

abstract class CartRepository {
  Future<Cart> getCart();

  Future<void> saveCart(Cart cart);
}
