import '../entities/order.dart';
import '../entities/place_order_params.dart';

abstract class OrderRepository {
  Future<void> placeOrder(PlaceOrderParams params);

  /// Lấy danh sách đơn hàng của người dùng hiện tại (mới nhất trước).
  Future<List<Order>> getOrders();

  /// Lấy toàn bộ đơn hàng trong hệ thống (cho Quản trị viên).
  Future<List<Order>> getAllOrders();

  Future<Order> getOrder(int id);

  /// Hủy đơn hàng kèm lý do tùy chọn.
  Future<void> cancelOrder(int id, {String? reason});

  /// Duyệt đơn hàng (Admin)
  Future<void> approveOrder(int id, {String? reason});

  /// Từ chối đơn hàng (Admin)
  Future<void> rejectOrder(int id, {String? reason});

  /// Giao đơn hàng (Admin)
  Future<void> shipOrder(int id, {String? reason});

  /// Hoàn thành đơn hàng (Admin)
  Future<void> completeOrder(int id, {String? reason});
}
