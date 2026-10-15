import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.orderId,
    required super.bookId,
    required super.quantity,
    required super.price,
  });

  /// [orderId] của đơn cha dùng khi JSON lồng không có trường `orderid`.
  factory OrderItemModel.fromJson(
    Map<String, dynamic> json, {
    required int orderId,
  }) =>
      OrderItemModel(
        orderId: (json['orderid'] as num?)?.toInt() ?? orderId,
        bookId: (json['bookid'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
        price: double.parse(json['price'].toString()),
      );
}
