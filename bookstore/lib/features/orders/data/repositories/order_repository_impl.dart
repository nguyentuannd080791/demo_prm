import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remote);

  final OrderRemoteDataSource _remote;

  @override
  Future<void> placeOrder(List<CartItem> items) => _remote.placeOrder(items);

  @override
  Future<List<Order>> getOrders() async {
    final orders = await _remote.fetchOrders();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  @override
  Future<Order> getOrder(int id) => _remote.fetchOrder(id);
}
