import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/place_order_params.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remote);

  final OrderRemoteDataSource _remote;

  @override
  Future<void> placeOrder(PlaceOrderParams params) => _remote.placeOrder(params);

  @override
  Future<List<Order>> getOrders() async {
    final orders = await _remote.fetchOrders();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  @override
  Future<List<Order>> getAllOrders() async {
    final orders = await _remote.fetchAllOrders();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  @override
  Future<Order> getOrder(int id) async {
    final results = await Future.wait([
      _remote.fetchOrder(id),
      _remote.fetchOrderItems(id),
    ]);
    final order = results[0] as Order;
    final items = results[1] as List<OrderItem>;
    return order.copyWith(items: items);
  }

  @override
  Future<void> cancelOrder(int id, {String? reason}) =>
      _remote.cancelOrder(id, reason: reason);

  @override
  Future<void> approveOrder(int id, {String? reason}) =>
      _remote.approveOrder(id, reason: reason);

  @override
  Future<void> rejectOrder(int id, {String? reason}) =>
      _remote.rejectOrder(id, reason: reason);

  @override
  Future<void> shipOrder(int id, {String? reason}) =>
      _remote.shipOrder(id, reason: reason);

  @override
  Future<void> completeOrder(int id, {String? reason}) =>
      _remote.completeOrder(id, reason: reason);
}
