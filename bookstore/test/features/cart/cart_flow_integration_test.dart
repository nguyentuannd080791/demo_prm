import 'package:bookstore/app/app.dart';
import 'package:bookstore/app/injection.dart';
import 'package:bookstore/features/auth/domain/entities/register_params.dart';
import 'package:bookstore/features/auth/domain/entities/user.dart';
import 'package:bookstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:bookstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:bookstore/features/books/domain/entities/book.dart';
import 'package:bookstore/features/books/domain/entities/book_filter_params.dart';
import 'package:bookstore/features/books/domain/entities/create_book_params.dart';
import 'package:bookstore/features/books/domain/repositories/book_repository.dart';
import 'package:bookstore/features/books/presentation/providers/book_provider.dart';
import 'package:bookstore/features/cart/domain/entities/cart.dart';
import 'package:bookstore/features/cart/domain/entities/cart_item.dart';
import 'package:bookstore/features/cart/domain/repositories/cart_repository.dart';
import 'package:bookstore/features/cart/presentation/pages/cart_page.dart';
import 'package:bookstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:bookstore/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:bookstore/features/favorites/presentation/providers/favorite_provider.dart';
import 'package:bookstore/features/orders/data/datasources/address_local_datasource.dart';
import 'package:bookstore/features/orders/domain/entities/order.dart';
import 'package:bookstore/features/orders/domain/entities/place_order_params.dart';
import 'package:bookstore/features/orders/domain/repositories/order_repository.dart';
import 'package:bookstore/features/orders/presentation/pages/checkout_page.dart';
import 'package:bookstore/features/orders/presentation/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepo implements AuthRepository {
  final User customer = const User(
    userId: 1,
    username: 'khachhang',
    role: 'CUSTOMER',
    fullName: 'Nguyễn Văn A',
  );

  @override
  Future<User> login({required String username, required String password}) async => customer;

  @override
  Future<User> register(RegisterParams params) async => customer;

  @override
  Future<User?> restoreSession() async => customer;

  @override
  Future<void> logout() async {}
}

class FakeBookRepo implements BookRepository {
  List<Book> bookList = [
    const Book(
      bookId: 1,
      bookName: 'Lập Trình Flutter',
      price: 150000,
      author: 'Google Team',
      publisher: 'NXB Khoa Học',
      summary: 'Sách học Flutter từ cơ bản đến nâng cao',
      status: true,
      stockQuantity: 10,
    ),
  ];

  @override
  Future<List<Book>> getBooks([BookFilterParams? params]) async => bookList;

  @override
  Future<Book> createBook(CreateBookParams params) async => throw UnimplementedError();

  @override
  Future<Book> updateBook(int id, CreateBookParams params) async => throw UnimplementedError();

  @override
  Future<void> deleteBook(int id) async {}
}

class FakeCartRepo implements CartRepository {
  Cart currentCart = const Cart([
    CartItem(
      bookId: 1,
      bookName: 'Lập Trình Flutter',
      price: 150000,
      quantity: 1,
    ),
  ]);

  @override
  Future<Cart> getCart() async => currentCart;

  @override
  Future<void> saveCart(Cart cart) async => currentCart = cart;
}

class FakeFavoriteRepo implements FavoriteRepository {
  @override
  Future<Set<int>> getFavoriteBookIds() async => {};

  @override
  Future<void> saveFavoriteBookIds(Set<int> bookIds) async {}
}

class FakeOrderRepo implements OrderRepository {
  @override
  Future<void> placeOrder(PlaceOrderParams params) async {}

  @override
  Future<List<Order>> getOrders() async => [];

  @override
  Future<List<Order>> getAllOrders() async => [];

  @override
  Future<Order> getOrder(int id) async => throw UnimplementedError();

  @override
  Future<void> cancelOrder(int id, {String? reason}) async {}

  @override
  Future<void> approveOrder(int id, {String? reason}) async {}

  @override
  Future<void> rejectOrder(int id, {String? reason}) async {}

  @override
  Future<void> shipOrder(int id, {String? reason}) async {}

  @override
  Future<void> completeOrder(int id, {String? reason}) async {}
}

void main() {
  testWidgets('Integration Flow Test: Luồng Giỏ hàng và Đặt hàng (Cart to Checkout)',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final authRepo = FakeAuthRepo();
    final authProvider = AuthProvider(authRepo);
    await authProvider.restoreSession();

    final bookRepo = FakeBookRepo();
    final bookProvider = BookProvider(bookRepo);
    await bookProvider.loadBooks();

    final cartRepo = FakeCartRepo();
    final cartProvider = CartProvider(cartRepo);
    await cartProvider.load();

    final favoriteProvider = FavoriteProvider(FakeFavoriteRepo());
    final orderProvider = OrderProvider(FakeOrderRepo());
    final addressLocalDataSource = AddressLocalDataSource(prefs);

    final dependencies = AppDependencies.custom(
      authProvider: authProvider,
      bookProvider: bookProvider,
      cartProvider: cartProvider,
      orderProvider: orderProvider,
      favoriteProvider: favoriteProvider,
      addressLocalDataSource: addressLocalDataSource,
    );

    // 1. Khởi chạy toàn bộ ứng dụng
    await tester.pumpWidget(App(dependencies: dependencies));
    await tester.pumpAndSettle();

    // 2. Vì user đã xác thực, AuthGate mở HomeShell.
    // Kiểm tra tab bar có điểm đến "Giỏ hàng"
    final cartTabFinder = find.text('Giỏ hàng');
    expect(cartTabFinder, findsWidgets);

    // 3. Người dùng chạm vào tab "Giỏ hàng" trên thanh điều hướng dưới
    await tester.tap(cartTabFinder.first);
    await tester.pumpAndSettle();

    // 4. Màn hình CartPage hiển thị cuốn sách đã có trong giỏ
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('Lập Trình Flutter'), findsOneWidget);
    expect(find.text('Tổng cộng (1 cuốn)'), findsOneWidget);

    // 5. Người dùng tương tác: Nhấn nút "+" để tăng số lượng lên 2 cuốn
    final increaseButton = find.byIcon(Icons.add_circle_outline);
    expect(increaseButton, findsOneWidget);
    await tester.tap(increaseButton);
    await tester.pumpAndSettle();

    // Xác minh số lượng và tổng tiền trên giao diện đã tăng
    expect(find.text('Tổng cộng (2 cuốn)'), findsOneWidget);
    expect(find.text('300.000 ₫'), findsOneWidget);

    // 6. Người dùng nhấn nút "Đặt hàng"
    final checkoutButton = find.widgetWithText(FilledButton, 'Đặt hàng');
    expect(checkoutButton, findsOneWidget);
    await tester.tap(checkoutButton);
    await tester.pumpAndSettle();

    // 7. Ứng dụng kiểm tra tồn kho thành công và điều hướng sang CheckoutPage (Xác nhận đặt hàng)
    expect(find.byType(CheckoutPage), findsOneWidget);
    expect(find.text('Xác nhận đặt hàng'), findsWidgets);
    expect(find.text('Địa chỉ nhận hàng'), findsOneWidget);
  });
}
