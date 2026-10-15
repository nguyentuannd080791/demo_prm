import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/books/presentation/providers/book_provider.dart';
import '../features/cart/presentation/providers/cart_provider.dart';
import '../features/favorites/presentation/providers/favorite_provider.dart';
import '../features/orders/presentation/providers/order_provider.dart';
import 'home_shell.dart';
import 'injection.dart';

class App extends StatelessWidget {
  const App({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: dependencies.authProvider,
        ),
        ChangeNotifierProvider<BookProvider>.value(
          value: dependencies.bookProvider,
        ),
        ChangeNotifierProvider<CartProvider>.value(
          value: dependencies.cartProvider,
        ),
        ChangeNotifierProvider<FavoriteProvider>.value(
          value: dependencies.favoriteProvider,
        ),
        ChangeNotifierProvider<OrderProvider>.value(
          value: dependencies.orderProvider,
        ),
      ],
      child: MaterialApp(
        title: 'Book Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.withAlpha(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        context.select<AuthProvider, bool>((auth) => auth.isAuthenticated);
    return isAuthenticated ? const HomeShell() : const LoginPage();
  }
}
