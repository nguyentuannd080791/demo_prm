import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import 'order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    super.userId,
    required super.date,
    required super.status,
    super.totalPrice,
    super.shippingAddress,
    super.phone,
    super.receiverName,
    super.note,
    super.approvedBy,
    super.approvedAt,
    super.items,
    super.username,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['orderId'] ?? json['id'];
    final id = (rawId as num?)?.toInt() ?? 0;

    final rawUserId = json['userId'] ?? json['userid'];
    final userId = (rawUserId as num?)?.toInt();

    final rawDate = json['orderDate'] ?? json['date'];
    final date = rawDate != null
        ? (DateTime.tryParse(rawDate.toString()) ?? DateTime.now())
        : DateTime.now();

    final rawApprovedAt = json['approvedAt'];
    final approvedAt = rawApprovedAt != null
        ? DateTime.tryParse(rawApprovedAt.toString())
        : null;

    final rawApprovedBy = json['approvedBy'];
    final approvedBy = (rawApprovedBy as num?)?.toInt();

    final rawTotal = json['totalAmount'] ?? json['totalPrice'];
    final totalAmount = rawTotal != null
        ? (double.tryParse(rawTotal.toString()) ?? 0.0)
        : 0.0;

    final rawItems = (json['items'] as List<dynamic>?) ?? const [];
    final items = <OrderItem>[
      for (final item in rawItems)
        if (item is Map<String, dynamic>)
          OrderItemModel.fromJson(item, orderId: id),
    ];

    final finalTotal = totalAmount > 0
        ? totalAmount
        : items.fold<double>(0, (sum, i) => sum + i.subtotal);

    return OrderModel(
      id: id,
      userId: userId,
      date: date,
      status: (json['status'] ?? 'PENDING').toString().trim().toUpperCase(),
      totalPrice: finalTotal,
      shippingAddress: (json['shippingAddress'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      receiverName: (json['receiverName'] ?? json['username'] ?? '').toString(),
      note: json['note']?.toString(),
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      items: items,
      username: (json['receiverName'] ?? json['username'] ?? '').toString(),
    );
  }
}
