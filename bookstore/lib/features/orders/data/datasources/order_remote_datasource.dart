import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/place_order_params.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> placeOrder(PlaceOrderParams params) async {
    await _client.post(
      ApiEndpoints.orders,
      body: {
        'date': DateTime.now().toIso8601String(),
        'status': 'PENDING',
        'receiverName': params.receiverName.trim(),
        'phone': params.phone.trim(),
        'shippingAddress': params.shippingAddress.trim(),
        'note': params.note?.trim() ?? '',
        'items': [
          for (final item in params.items)
            {
              'bookid': item.bookId,
              'quantity': item.quantity,
            },
        ],
      },
    );
  }

  /// Lấy danh sách đơn hàng của người dùng đang đăng nhập qua GET /api/orders/my-orders
  Future<List<OrderModel>> fetchOrders() async {
    final json = await _client.get(ApiEndpoints.myOrders) as List<dynamic>;
    return json
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> fetchOrder(int id) async {
    final json = await _client.get(ApiEndpoints.order(id));
    return OrderModel.fromJson(json as Map<String, dynamic>);
  }

  /// Lấy các dòng sách trong đơn qua GET /api/orders/{id}/items
  Future<List<OrderItemModel>> fetchOrderItems(int id) async {
    final json = await _client.get(ApiEndpoints.orderItems(id)) as List<dynamic>;
    return json
        .map((item) =>
            OrderItemModel.fromJson(item as Map<String, dynamic>, orderId: id))
        .toList();
  }

  /// Lấy danh sách toàn bộ đơn hàng (cho Quản trị viên) qua GET /api/orders
  Future<List<OrderModel>> fetchAllOrders() async {
    final json = await _client.get(ApiEndpoints.orders) as List<dynamic>;
    return json
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Hủy đơn hàng qua POST /api/orders/{id}/cancel
  Future<void> cancelOrder(int id, {String? reason}) async {
    await _client.post(
      ApiEndpoints.cancelOrder(id),
      body: {
        'reason': reason != null && reason.trim().isNotEmpty ? reason.trim() : '',
      },
    );
  }

  /// Duyệt đơn hàng qua POST /api/orders/{id}/approve
  Future<void> approveOrder(int id, {String? reason}) async {
    await _client.post(
      ApiEndpoints.approveOrder(id),
      body: {
        'reason': reason != null && reason.trim().isNotEmpty ? reason.trim() : '',
      },
    );
  }

  /// Từ chối đơn hàng qua POST /api/orders/{id}/reject
  Future<void> rejectOrder(int id, {String? reason}) async {
    await _client.post(
      ApiEndpoints.rejectOrder(id),
      body: {
        'reason': reason != null && reason.trim().isNotEmpty ? reason.trim() : '',
      },
    );
  }

  /// Đánh dấu đang giao hàng qua POST /api/orders/{id}/ship
  Future<void> shipOrder(int id, {String? reason}) async {
    await _client.post(
      ApiEndpoints.shipOrder(id),
      body: {
        'reason': reason != null && reason.trim().isNotEmpty ? reason.trim() : '',
      },
    );
  }

  /// Đánh dấu hoàn thành đơn qua POST /api/orders/{id}/complete
  Future<void> completeOrder(int id, {String? reason}) async {
    await _client.post(
      ApiEndpoints.completeOrder(id),
      body: {
        'reason': reason != null && reason.trim().isNotEmpty ? reason.trim() : '',
      },
    );
  }
}
