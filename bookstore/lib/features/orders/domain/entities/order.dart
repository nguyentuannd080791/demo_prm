import 'order_item.dart';

class Order {
  const Order({
    required this.id,
    this.userId,
    required this.date,
    required this.status,
    this.totalPrice = 0.0,
    this.shippingAddress = '',
    this.phone = '',
    this.receiverName = '',
    this.note,
    this.approvedBy,
    this.approvedAt,
    this.items = const [],
    this.username = '',
  });

  final int id;
  final int? userId;
  final DateTime date;
  final String status;
  final double totalPrice;
  final String shippingAddress;
  final String phone;
  final String receiverName;
  final String? note;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String username;

  /// Có thể rỗng khi API danh sách không kèm chi tiết.
  final List<OrderItem> items;

  /// Đơn có thể hủy nếu đang ở trạng thái PENDING hoặc APPROVED (theo nghiệp vụ backend).
  bool get canCancel {
    final s = status.toUpperCase().trim();
    return s == 'PENDING' || s == 'APPROVED';
  }

  Order copyWith({
    int? id,
    int? userId,
    DateTime? date,
    String? status,
    double? totalPrice,
    String? shippingAddress,
    String? phone,
    String? receiverName,
    String? note,
    int? approvedBy,
    DateTime? approvedAt,
    List<OrderItem>? items,
    String? username,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phone: phone ?? this.phone,
      receiverName: receiverName ?? this.receiverName,
      note: note ?? this.note,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      items: items ?? this.items,
      username: username ?? this.username,
    );
  }
}
