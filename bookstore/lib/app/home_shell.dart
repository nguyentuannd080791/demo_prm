import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/books/presentation/pages/add_book_page.dart';
import '../features/books/presentation/pages/book_list_page.dart';
import '../features/books/presentation/providers/book_provider.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/cart/presentation/providers/cart_provider.dart';
import '../features/favorites/presentation/pages/favorite_page.dart';
import '../features/favorites/presentation/providers/favorite_provider.dart';
import '../features/orders/presentation/pages/admin_order_list_page.dart';
import '../features/orders/presentation/pages/order_list_page.dart';
import '../features/orders/presentation/providers/order_provider.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _customerTitles = [
    'Danh sách sách',
    'Sách yêu thích',
    'Giỏ hàng',
    'Đơn hàng của tôi',
  ];

  static const _adminTitles = [
    'Quản lý sách',
    'Quản lý đơn hàng',
    'Sách yêu thích',
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Nạp dữ liệu của tài khoản hiện tại sau frame đầu tiên để tránh lỗi setState trong lúc build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CartProvider>().load();
      context.read<FavoriteProvider>().load();
      context.read<OrderProvider>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount =
        context.select<CartProvider, int>((cart) => cart.totalQuantity);
    final favCount =
        context.select<FavoriteProvider, int>((fav) => fav.count);
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.isAdmin ?? false;

    final titles = isAdmin ? _adminTitles : _customerTitles;
    if (_index >= titles.length) {
      _index = 0;
    }

    final pages = isAdmin
        ? const <Widget>[
            BookListPage(),
            AdminOrderListPage(),
            FavoritePage(),
          ]
        : const <Widget>[
            BookListPage(),
            FavoritePage(),
            CartPage(),
            OrderListPage(),
          ];

    final destinations = isAdmin
        ? const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Quản lý Sách',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Quản lý Đơn',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Yêu thích',
            ),
          ]
        : <NavigationDestination>[
            const NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Sách',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favCount > 0,
                label: Text('$favCount'),
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: Badge(
                isLabelVisible: favCount > 0,
                label: Text('$favCount'),
                child: const Icon(Icons.favorite),
              ),
              label: 'Yêu thích',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Giỏ hàng',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Đơn hàng',
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 30),
            tooltip: 'Tài khoản',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text(
                      'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(false),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(true),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                }
              }
            },
            itemBuilder: (popupContext) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: Theme.of(popupContext).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Xin chào, ${user?.username ?? 'Khách'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(popupContext).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isAdmin)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(popupContext)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'QUẢN TRỊ VIÊN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(popupContext)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      // Chỉ hiển thị nút Thêm sách cho Quản trị viên
      floatingActionButton: (_index == 0 && isAdmin)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AddBookPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm sách'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          if (index == 0 && _index != 0) {
            final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
            context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
          }
          setState(() => _index = index);
        },
        destinations: destinations,
      ),
    );
  }
}
