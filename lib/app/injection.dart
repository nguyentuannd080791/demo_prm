import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/books/data/datasources/book_remote_datasource.dart';
import '../features/books/data/repositories/book_repository_impl.dart';
import '../features/books/presentation/providers/book_provider.dart';
import '../features/cart/data/datasources/cart_local_datasource.dart';
import '../features/cart/data/repositories/cart_repository_impl.dart';
import '../features/cart/presentation/providers/cart_provider.dart';
import '../features/favorites/data/datasources/favorite_prefs_datasource.dart';
import '../features/favorites/data/repositories/favorite_repository_impl.dart';
import '../features/favorites/presentation/providers/favorite_provider.dart';
import '../features/orders/data/datasources/order_remote_datasource.dart';
import '../features/orders/data/repositories/order_repository_impl.dart';
import '../features/orders/presentation/providers/order_provider.dart';

/// Composition root: the only place that knows concrete implementations.
class AppDependencies {
  AppDependencies._({
    required this.authProvider,
    required this.bookProvider,
    required this.cartProvider,
    required this.orderProvider,
    required this.favoriteProvider,
  });

  final AuthProvider authProvider;
  final BookProvider bookProvider;
  final CartProvider cartProvider;
  final OrderProvider orderProvider;
  final FavoriteProvider favoriteProvider;

  static Future<AppDependencies> create() async {
    final prefs = await SharedPreferences.getInstance();
    final authLocal = AuthLocalDataSource(prefs);

    late final AuthProvider authProvider;
    final apiClient = ApiClient(
      httpClient: http.Client(),
      readToken: authLocal.readToken,
      // Token hết hạn/bị từ chối -> đăng xuất, _AuthGate tự quay về LoginPage.
      onUnauthorized: () => authProvider.logout(),
    );

    authProvider = AuthProvider(
      AuthRepositoryImpl(AuthRemoteDataSource(apiClient), authLocal),
    );
    final bookProvider = BookProvider(
      BookRepositoryImpl(BookRemoteDataSource(apiClient)),
    );
    final cartProvider = CartProvider(
      CartRepositoryImpl(
        CartLocalDataSource(prefs, () => authProvider.user?.username),
      ),
    );
    final favoriteProvider = FavoriteProvider(
      FavoriteRepositoryImpl(
        FavoritePrefsDataSource(prefs, () => authProvider.user?.username),
      ),
    );
    final orderProvider = OrderProvider(
      OrderRepositoryImpl(OrderRemoteDataSource(apiClient)),
    );

    return AppDependencies._(
      authProvider: authProvider,
      bookProvider: bookProvider,
      cartProvider: cartProvider,
      orderProvider: orderProvider,
      favoriteProvider: favoriteProvider,
    );
  }
}
