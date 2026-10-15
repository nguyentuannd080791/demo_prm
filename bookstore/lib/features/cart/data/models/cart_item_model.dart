import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.bookId,
    required super.bookName,
    required super.price,
    required super.quantity,
  });

  factory CartItemModel.fromEntity(CartItem item) => CartItemModel(
        bookId: item.bookId,
        bookName: item.bookName,
        price: item.price,
        quantity: item.quantity,
      );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        bookId: json['bookId'] as int,
        bookName: json['bookName'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'bookName': bookName,
        'price': price,
        'quantity': quantity,
      };
}
