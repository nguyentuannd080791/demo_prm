import 'package:bookstore/features/books/domain/entities/book.dart';
import 'package:bookstore/features/cart/domain/entities/cart.dart';
import 'package:bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:bookstore/features/cart/domain/repositories/cart_repository.dart';
import 'package:bookstore/features/cart/presentation/logic/cart_logic.dart';
import 'package:bookstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake implementation của CartRepository để phục vụ Unit Test
class FakeCartRepository implements CartRepository {
  Cart storedCart = const Cart();
  bool wasSaved = false;

  @override
  Future<Cart> getCart() async {
    return storedCart;
  }

  @override
  Future<void> saveCart(Cart cart) async {
    storedCart = cart;
    wasSaved = true;
  }
}

void main() {
  group('1. CartItem Entity Unit Tests', () {
    test('subtotal tính đúng bằng price * quantity', () {
      const item = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 150000,
        quantity: 3,
      );

      expect(item.subtotal, 450000.0);
    });

    test('copyWith cập nhật số lượng và giữ nguyên các trường khác', () {
      const item = CartItem(
        bookId: 1,
        bookName: 'Clean Architecture',
        price: 200000,
        quantity: 1,
      );

      final updated = item.copyWith(quantity: 4);

      expect(updated.bookId, 1);
      expect(updated.bookName, 'Clean Architecture');
      expect(updated.price, 200000);
      expect(updated.quantity, 4);
      expect(updated.subtotal, 800000.0);
    });
  });

  group('2. Cart Entity Unit Tests', () {
    test('Giỏ hàng mặc định khởi tạo là rỗng', () {
      const cart = Cart();

      expect(cart.isEmpty, isTrue);
      expect(cart.items, isEmpty);
      expect(cart.totalQuantity, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('add: thêm sản phẩm mới vào giỏ hàng trống', () {
      const cart = Cart();
      const item = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 2,
      );

      final newCart = cart.add(item);

      expect(newCart.isEmpty, isFalse);
      expect(newCart.items.length, 1);
      expect(newCart.totalQuantity, 2);
      expect(newCart.totalPrice, 200000.0);
    });

    test('add: thêm sản phẩm đã có thì cộng dồn số lượng', () {
      const item1 = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 2,
      );
      final cart = const Cart().add(item1);

      // Thêm tiếp 3 cuốn cùng bookId = 1
      const itemSame = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 3,
      );
      final updatedCart = cart.add(itemSame);

      expect(updatedCart.items.length, 1);
      expect(updatedCart.items.first.quantity, 5);
      expect(updatedCart.totalQuantity, 5);
      expect(updatedCart.totalPrice, 500000.0);
    });

    test('add: thêm sản phẩm khác bookId sẽ tạo phần tử mới', () {
      const item1 = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 1,
      );
      const item2 = CartItem(
        bookId: 2,
        bookName: 'Refactoring',
        price: 150000,
        quantity: 2,
      );

      final cart = const Cart().add(item1).add(item2);

      expect(cart.items.length, 2);
      expect(cart.totalQuantity, 3);
      expect(cart.totalPrice, 400000.0);
    });

    test('changeQuantity: cập nhật số lượng hợp lệ (> 0)', () {
      const item = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 2,
      );
      final cart = const Cart().add(item);

      final updated = cart.changeQuantity(1, 5);

      expect(updated.items.first.quantity, 5);
      expect(updated.totalQuantity, 5);
      expect(updated.totalPrice, 500000.0);
    });

    test('changeQuantity: số lượng bằng 0 hoặc âm sẽ tự động xóa khỏi giỏ', () {
      const item = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 2,
      );
      final cart = const Cart().add(item);

      final zeroCart = cart.changeQuantity(1, 0);
      expect(zeroCart.isEmpty, isTrue);

      final negativeCart = cart.changeQuantity(1, -2);
      expect(negativeCart.isEmpty, isTrue);
    });

    test('remove: xóa đúng sản phẩm theo bookId', () {
      const item1 = CartItem(
        bookId: 1,
        bookName: 'Sách 1',
        price: 50000,
        quantity: 1,
      );
      const item2 = CartItem(
        bookId: 2,
        bookName: 'Sách 2',
        price: 70000,
        quantity: 1,
      );

      final cart = const Cart().add(item1).add(item2);
      final updated = cart.remove(1);

      expect(updated.items.length, 1);
      expect(updated.items.first.bookId, 2);
      expect(updated.totalPrice, 70000.0);
    });
  });

  group('3. CartLogic Unit Tests', () {
    final sampleBooks = [
      const Book(
        bookId: 10,
        bookName: 'Flutter in Action',
        price: 180000,
        author: 'Eric Windmill',
        publisher: 'Manning',
        summary: 'Flutter guide',
        status: true,
        stockQuantity: 15,
      ),
      const Book(
        bookId: 20,
        bookName: 'Dart Apprentice',
        price: 120000,
        author: 'Raywenderlich',
        publisher: 'Razeware',
        summary: 'Dart basics',
        status: true,
        stockQuantity: 0,
      ),
    ];

    test('getBookStock: trả về đúng số lượng tồn kho khi sách tồn tại', () {
      final stock1 = CartLogic.getBookStock(sampleBooks, 10);
      final stock2 = CartLogic.getBookStock(sampleBooks, 20);

      expect(stock1, 15);
      expect(stock2, 0);
    });

    test('getBookStock: trả về null khi không tìm thấy sách', () {
      final stock = CartLogic.getBookStock(sampleBooks, 999);
      expect(stock, isNull);
    });
  });

  group('4. CartProvider Unit Tests', () {
    late FakeCartRepository fakeRepo;
    late CartProvider provider;

    setUp(() {
      fakeRepo = FakeCartRepository();
      provider = CartProvider(fakeRepo);
    });

    test('load: nạp giỏ hàng từ CartRepository', () async {
      fakeRepo.storedCart = const Cart([
        CartItem(
          bookId: 5,
          bookName: 'Design Patterns',
          price: 250000,
          quantity: 2,
        ),
      ]);

      await provider.load();

      expect(provider.cart.items.length, 1);
      expect(provider.totalQuantity, 2);
      expect(provider.cart.items.first.bookName, 'Design Patterns');
    });

    test('add: thêm món vào CartProvider và lưu vào repository', () async {
      const item = CartItem(
        bookId: 1,
        bookName: 'Refactoring',
        price: 190000,
        quantity: 1,
      );

      await provider.add(item);

      expect(provider.cart.items.length, 1);
      expect(provider.totalQuantity, 1);
      expect(fakeRepo.wasSaved, isTrue);
      expect(fakeRepo.storedCart.items.first.bookName, 'Refactoring');
    });

    test('changeQuantity: cập nhật số lượng qua CartProvider', () async {
      const item = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 2,
      );
      await provider.add(item);

      await provider.changeQuantity(1, 4);

      expect(provider.cart.items.first.quantity, 4);
      expect(fakeRepo.storedCart.items.first.quantity, 4);
    });

    test('remove: xóa sản phẩm qua CartProvider', () async {
      const item = CartItem(
        bookId: 1,
        bookName: 'Clean Code',
        price: 100000,
        quantity: 2,
      );
      await provider.add(item);

      await provider.remove(1);

      expect(provider.cart.isEmpty, isTrue);
      expect(fakeRepo.storedCart.isEmpty, isTrue);
    });

    test('clear: làm trống giỏ hàng qua CartProvider', () async {
      const item1 = CartItem(bookId: 1, bookName: 'A', price: 10, quantity: 1);
      const item2 = CartItem(bookId: 2, bookName: 'B', price: 20, quantity: 2);
      await provider.add(item1);
      await provider.add(item2);

      await provider.clear();

      expect(provider.cart.isEmpty, isTrue);
      expect(fakeRepo.storedCart.isEmpty, isTrue);
    });
  });
}
