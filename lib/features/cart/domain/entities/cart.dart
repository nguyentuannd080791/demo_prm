import 'cart_item.dart';

/// Bất biến: mỗi thao tác trả về một Cart mới.
class Cart {
  const Cart([this.items = const []]);

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold<double>(0, (sum, item) => sum + item.subtotal);

  /// Thêm mới, hoặc cộng dồn số lượng nếu sách đã có trong giỏ.
  Cart add(CartItem item) {
    final index = items.indexWhere((e) => e.bookId == item.bookId);
    if (index == -1) return Cart([...items, item]);
    final updated = [...items];
    updated[index] = updated[index]
        .copyWith(quantity: updated[index].quantity + item.quantity);
    return Cart(updated);
  }

  /// quantity <= 0 thì xóa khỏi giỏ.
  Cart changeQuantity(int bookId, int quantity) {
    if (quantity <= 0) return remove(bookId);
    return Cart([
      for (final item in items)
        item.bookId == bookId ? item.copyWith(quantity: quantity) : item,
    ]);
  }

  Cart remove(int bookId) =>
      Cart(items.where((item) => item.bookId != bookId).toList());
}
