class CartItem {
  const CartItem({
    required this.bookId,
    required this.bookName,
    required this.price,
    required this.quantity,
  });

  final int bookId;
  final String bookName;
  final double price;
  final int quantity;

  double get subtotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        bookId: bookId,
        bookName: bookName,
        price: price,
        quantity: quantity ?? this.quantity,
      );
}
