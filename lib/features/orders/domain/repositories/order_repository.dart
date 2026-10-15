import '../../../cart/domain/entities/cart_item.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<void> placeOrder(List<CartItem> items);

  /// Mới nhất trước.
  Future<List<Order>> getOrders();

  Future<Order> getOrder(int id);
}
