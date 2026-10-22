import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.orderId,
    required super.bookId,
    required super.quantity,
    required super.price,
  });

  /// [orderId] của đơn cha dùng khi JSON không có trường `orderId` hoặc `orderid`.
  factory OrderItemModel.fromJson(
    Map<String, dynamic> json, {
    int? orderId,
  }) {
    final rawOrderId = json['orderId'] ?? json['orderid'];
    final rawBookId = json['bookId'] ?? json['bookid'];
    final rawPrice = json['unitPrice'] ?? json['price'] ?? 0;
    return OrderItemModel(
      orderId: (rawOrderId as num?)?.toInt() ?? orderId ?? 0,
      bookId: (rawBookId as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      price: double.tryParse(rawPrice.toString()) ?? 0.0,
    );
  }
}
