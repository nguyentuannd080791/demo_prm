import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/home_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/datasources/address_local_datasource.dart';
import '../../domain/entities/place_order_params.dart';
import '../../domain/entities/shipping_address.dart';
import '../providers/order_provider.dart';
import '../widgets/address_selector_sheet.dart';

/// Lớp chịu trách nhiệm toàn bộ logic xử lý cho màn hình Checkout (SOLID - SRP)
/// Quản lý state, form controllers, validation tồn kho, lưu địa chỉ và gửi đơn hàng.
class CheckoutLogic extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final newReceiverNameController = TextEditingController();
  final newPhoneController = TextEditingController();
  final newAddressController = TextEditingController();

  ShippingAddress? selectedAddress;
  bool isInitialized = false;

  /// Khởi tạo dữ liệu người dùng và sổ địa chỉ ban đầu
  void init(BuildContext context) {
    if (!isInitialized) {
      final user = context.read<AuthProvider>().user;
      final userId = user?.userId ?? 0;
      final ds = context.read<AddressLocalDataSource>();

      final defaultAddress = ds.getDefaultOrFirst(userId);
      if (defaultAddress != null) {
        selectedAddress = defaultAddress;
      } else {
        newReceiverNameController.text = user?.fullName ?? '';
      }
      isInitialized = true;
      notifyListeners();
    }
  }

  /// Cập nhật địa chỉ nhận hàng đã chọn
  void selectAddress(ShippingAddress address) {
    selectedAddress = address;
    notifyListeners();
  }

  /// Mở bottom sheet chọn địa chỉ từ sổ địa chỉ
  void openAddressSelector(BuildContext context, int userId, String? defaultFullName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddressSelectorSheet(
        userId: userId,
        selectedAddressId: selectedAddress?.id,
        defaultReceiverName: defaultFullName,
        onSelect: (address) {
          selectAddress(address);
        },
      ),
    );
  }

  /// Kiểm tra và tự động điều chỉnh các mặt hàng trong giỏ hàng nếu tồn kho thay đổi hoặc sách ngừng bán
  Future<List<String>> validateAndAdjustCart(
    BuildContext context, {
    bool showModalIfChanged = true,
  }) async {
    final bookProvider = context.read<BookProvider>();
    final cartProvider = context.read<CartProvider>();
    final books = bookProvider.books;

    final adjustments = <String>[];
    final itemsToCheck = List.of(cartProvider.cart.items);

    for (final item in itemsToCheck) {
      final book = books.cast<Book?>().firstWhere(
            (b) => b?.bookId == item.bookId,
            orElse: () => null,
          );

      if (book == null || !book.status || book.stockQuantity <= 0) {
        await cartProvider.remove(item.bookId);
        final reason = (book != null && !book.status)
            ? 'tạm dừng bán'
            : 'đã hết hàng';
        adjustments.add('Sách "${item.bookName}" hiện $reason nên đã được tự động loại khỏi đơn hàng.');
      } else if (item.quantity > book.stockQuantity) {
        await cartProvider.changeQuantity(item.bookId, book.stockQuantity);
        adjustments.add(
          'Sách "${item.bookName}" chỉ còn ${book.stockQuantity} cuốn trong kho (bạn chọn ${item.quantity}). Hệ thống đã điều chỉnh về ${book.stockQuantity} cuốn.',
        );
      }
    }

    if (adjustments.isNotEmpty && context.mounted && showModalIfChanged) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.info_outline, color: Colors.orange, size: 48),
          title: const Text('Cập nhật số lượng giỏ hàng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Một số sản phẩm có sự thay đổi về tồn kho. Hệ thống đã tự động điều chỉnh lại để thông tin đặt hàng chính xác:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                for (final msg in adjustments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            msg,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
    }

    return adjustments;
  }

  /// Thực hiện đặt hàng và điều hướng
  Future<void> submitOrder(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    final userId = user?.userId ?? 0;
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final addressDs = context.read<AddressLocalDataSource>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    // Validate lại số lượng tồn kho trước khi đặt hàng
    final adjustments = await validateAndAdjustCart(context, showModalIfChanged: true);
    if (adjustments.isNotEmpty) {
      return; // Dừng lại để người dùng xem thông tin điều chỉnh
    }

    if (!context.mounted) return;

    if (cartProvider.cart.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng trống hoặc các sản phẩm đều không còn mở bán.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String receiverName;
    String phone;
    String addressText;

    if (selectedAddress != null) {
      receiverName = selectedAddress!.receiverName;
      phone = selectedAddress!.phone;
      addressText = selectedAddress!.address;
    } else {
      // Trường hợp chưa có địa chỉ, validate form nhập trực tiếp
      if (!formKey.currentState!.validate()) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Vui lòng kiểm tra lại thông tin người nhận và địa chỉ'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      receiverName = newReceiverNameController.text.trim();
      phone = newPhoneController.text.trim();
      addressText = newAddressController.text.trim();

      // Tự động lưu địa chỉ này vào sổ địa chỉ để sử dụng cho lần sau
      final newAddress = ShippingAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        receiverName: receiverName,
        phone: phone,
        address: addressText,
        isDefault: true,
      );
      await addressDs.saveAddress(userId, newAddress);
      selectedAddress = newAddress;
      notifyListeners();
    }

    final params = PlaceOrderParams(
      items: cartProvider.cart.items,
      receiverName: receiverName,
      phone: phone,
      shippingAddress: addressText,
      note: noteController.text.trim(),
    );

    final error = await orderProvider.placeOrder(params);

    if (!context.mounted) return;

    if (error != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    await cartProvider.clear();
    final isAdmin = user?.isAdmin ?? false;
    if (context.mounted) {
      await context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 56),
        title: const Text('Đặt hàng thành công!'),
        content: Text(
          'Đơn hàng đã được tạo thành công cho người nhận "$receiverName". Bạn có thể theo dõi trong mục "Đơn hàng".',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Chuyển sang tab Đơn hàng trên HomeShell (Customer: tab 3, Admin: tab 1)
              HomeShell.tabSwitcher.value = isAdmin ? 1 : 3;
              navigator.popUntil((route) => route.isFirst);
              if (context.mounted) {
                context.read<OrderProvider>().loadOrders(isAdmin: isAdmin);
              }
            },
            child: const Text('Xem đơn hàng'),
          ),
        ],
      ),
    );
  }

  // --- Các hàm Validator tách riêng ---
  String? validateReceiverName(String? val) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập họ và tên người nhận';
    }
    if (text.length < 2 || text.length > 100) {
      return 'Họ tên phải từ 2 đến 100 ký tự';
    }
    return null;
  }

  String? validatePhone(String? val) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!PlaceOrderParams.vnPhoneRegex.hasMatch(text)) {
      return 'SĐT gồm 10 chữ số (đầu 03, 05, 07, 08, 09)';
    }
    return null;
  }

  String? validateAddress(String? val) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập địa chỉ nhận hàng';
    }
    if (text.length < 5 || text.length > 1000) {
      return 'Địa chỉ phải từ 5 đến 1000 ký tự';
    }
    return null;
  }

  @override
  void dispose() {
    noteController.dispose();
    newReceiverNameController.dispose();
    newPhoneController.dispose();
    newAddressController.dispose();
    super.dispose();
  }
}
