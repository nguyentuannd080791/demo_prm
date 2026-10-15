import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> placeOrder(List<CartItem> items) async {
    await _client.post(
      ApiEndpoints.orders,
      body: {
        'items': [
          for (final item in items)
            {
              'bookid': item.bookId,
              'quantity': item.quantity,
              'price': item.price,
            },
        ],
      },
    );
  }

  Future<List<OrderModel>> fetchOrders() async {
    final json = await _client.get(ApiEndpoints.orders) as List<dynamic>;
    return json
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> fetchOrder(int id) async {
    final json = await _client.get(ApiEndpoints.order(id));
    return OrderModel.fromJson(json as Map<String, dynamic>);
  }
}
