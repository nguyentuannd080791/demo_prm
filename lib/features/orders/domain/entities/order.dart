import 'order_item.dart';

class Order {
  const Order({
    required this.id,
    required this.username,
    required this.date,
    required this.status,
    this.items = const [],
  });

  final int id;
  final String username;
  final DateTime date;
  final String status;

  /// Có thể rỗng khi API danh sách không kèm chi tiết.
  final List<OrderItem> items;

  double get totalPrice =>
      items.fold<double>(0, (sum, item) => sum + item.subtotal);
}
