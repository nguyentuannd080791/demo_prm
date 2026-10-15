class OrderItem {
  const OrderItem({
    required this.orderId,
    required this.bookId,
    required this.quantity,
    required this.price,
  });

  final int orderId;
  final int bookId;
  final int quantity;
  final double price;

  double get subtotal => price * quantity;
}
