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
import 'package:bookstore/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeCartRepository implements CartRepository {
  Cart storedCart = const Cart();

  @override
  Future<Cart> getCart() async => storedCart;

  @override
  Future<void> saveCart(Cart cart) async => storedCart = cart;
}

class FakeBookRepository implements BookRepository {
  List<Book> books = [];

  @override
  Future<List<Book>> getBooks([BookFilterParams? params]) async => books;

  @override
  Future<Book> createBook(CreateBookParams params) async => throw UnimplementedError();

  @override
  Future<Book> updateBook(int id, CreateBookParams params) async => throw UnimplementedError();

  @override
  Future<void> deleteBook(int id) async {}
}

Widget createCartScreen({
  required CartProvider cartProvider,
  required BookProvider bookProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
      ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: CartPage(),
      ),
    ),
  );
}

void main() {
  late FakeCartRepository fakeCartRepo;
  late CartProvider cartProvider;
  late FakeBookRepository fakeBookRepo;
  late BookProvider bookProvider;

  setUp(() {
    fakeCartRepo = FakeCartRepository();
    cartProvider = CartProvider(fakeCartRepo);

    fakeBookRepo = FakeBookRepository();
    bookProvider = BookProvider(fakeBookRepo);
  });

  group('CartPage Widget Tests', () {
    testWidgets('Hiển thị giao diện giỏ hàng trống khi không có sản phẩm',
        (tester) async {
      await tester.pumpWidget(
        createCartScreen(
          cartProvider: cartProvider,
          bookProvider: bookProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Kiểm tra icon giỏ hàng trống và thông điệp
      expect(find.byIcon(Icons.remove_shopping_cart_outlined), findsOneWidget);
      expect(find.text('Giỏ hàng của bạn đang trống'), findsOneWidget);
      expect(
        find.text('Hãy tìm và chọn thêm những cuốn sách hay vào giỏ hàng nhé!'),
        findsOneWidget,
      );

      // Nút Đặt hàng không được hiển thị khi giỏ trống
      expect(find.text('Đặt hàng'), findsNothing);
    });

    testWidgets('Hiển thị danh sách sản phẩm, số lượng và tổng tiền chính xác',
        (tester) async {
      // Chuẩn bị giỏ có 2 sản phẩm
      await cartProvider.add(
        const CartItem(
          bookId: 1,
          bookName: 'Clean Code',
          price: 100000,
          quantity: 2,
        ),
      );
      await cartProvider.add(
        const CartItem(
          bookId: 2,
          bookName: 'Design Patterns',
          price: 250000,
          quantity: 1,
        ),
      );

      await tester.pumpWidget(
        createCartScreen(
          cartProvider: cartProvider,
          bookProvider: bookProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Kiểm tra số lượng item hiển thị
      expect(find.byType(CartItemTile), findsNWidgets(2));
      expect(find.text('Clean Code'), findsOneWidget);
      expect(find.text('Design Patterns'), findsOneWidget);

      // Kiểm tra footer hiển thị tổng số cuốn và tổng tiền (2*100k + 1*250k = 450k)
      expect(find.text('Tổng cộng (3 cuốn)'), findsOneWidget);
      expect(find.text('450.000 ₫'), findsOneWidget);
      expect(find.text('Đặt hàng'), findsOneWidget);
    });

    testWidgets('Nhấn nút tăng (+) tăng số lượng và cập nhật tổng tiền',
        (tester) async {
      await cartProvider.add(
        const CartItem(
          bookId: 1,
          bookName: 'Clean Code',
          price: 100000,
          quantity: 1,
        ),
      );

      await tester.pumpWidget(
        createCartScreen(
          cartProvider: cartProvider,
          bookProvider: bookProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Ban đầu có 2 chỗ hiển thị "100.000 ₫": đơn giá của item và tổng tiền ở footer
      expect(find.text('Tổng cộng (1 cuốn)'), findsOneWidget);
      expect(find.text('100.000 ₫'), findsNWidgets(2));

      // Nhấn nút tăng số lượng
      final increaseButton = find.byIcon(Icons.add_circle_outline);
      expect(increaseButton, findsOneWidget);
      await tester.tap(increaseButton);
      await tester.pumpAndSettle();

      // Xác minh số lượng và tổng tiền cập nhật
      expect(cartProvider.cart.items.first.quantity, 2);
      expect(find.text('Tổng cộng (2 cuốn)'), findsOneWidget);
      expect(find.text('200.000 ₫'), findsOneWidget); // Tổng tiền mới
      expect(find.text('100.000 ₫'), findsOneWidget); // Đơn giá của item
    });

    testWidgets('Nhấn nút xóa icon thùng rác loại bỏ sản phẩm và chuyển về trạng thái rỗng',
        (tester) async {
      await cartProvider.add(
        const CartItem(
          bookId: 1,
          bookName: 'Clean Code',
          price: 100000,
          quantity: 1,
        ),
      );

      await tester.pumpWidget(
        createCartScreen(
          cartProvider: cartProvider,
          bookProvider: bookProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Nhấn nút xóa
      final deleteButton = find.byIcon(Icons.delete_outline);
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Giỏ hàng trở về rỗng
      expect(cartProvider.cart.isEmpty, isTrue);
      expect(find.text('Giỏ hàng của bạn đang trống'), findsOneWidget);
    });

    testWidgets('Vô hiệu hóa nút tăng (+) khi số lượng đạt giới hạn tồn kho',
        (tester) async {
      // Mock sách trong kho có tồn kho là 2
      fakeBookRepo.books = [
        const Book(
          bookId: 1,
          bookName: 'Clean Code',
          price: 100000,
          author: 'Robert C. Martin',
          publisher: 'Prentice Hall',
          summary: 'Clean code guide',
          status: true,
          stockQuantity: 2,
        ),
      ];
      await bookProvider.loadBooks();

      // Giỏ hàng đang có số lượng = 2 (bằng đúng tồn kho)
      await cartProvider.add(
        const CartItem(
          bookId: 1,
          bookName: 'Clean Code',
          price: 100000,
          quantity: 2,
        ),
      );

      await tester.pumpWidget(
        createCartScreen(
          cartProvider: cartProvider,
          bookProvider: bookProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Kiểm tra có thông tin tồn kho
      expect(find.text('(Kho: 2)'), findsOneWidget);

      // Nút tăng phải bị disable (onPressed == null)
      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add_circle_outline),
      );
      expect(iconButton.onPressed, isNull);
    });
  });
}
