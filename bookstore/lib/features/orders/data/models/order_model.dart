import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import 'order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.username,
    required super.date,
    required super.status,
    super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num).toInt();
    final rawItems = (json['items'] as List<dynamic>?) ?? const [];
    return OrderModel(
      id: id,
      username: (json['username'] ?? '').toString(),
      date: DateTime.parse(json['date'].toString()),
      status: (json['status'] ?? '').toString(),
      items: <OrderItem>[
        for (final item in rawItems)
          OrderItemModel.fromJson(item as Map<String, dynamic>, orderId: id),
      ],
    );
  }
}
