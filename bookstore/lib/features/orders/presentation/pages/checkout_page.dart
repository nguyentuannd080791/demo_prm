import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/datasources/address_local_datasource.dart';
import '../../domain/entities/place_order_params.dart';
import '../../domain/entities/shipping_address.dart';
import '../providers/order_provider.dart';
import '../widgets/address_selector_sheet.dart';

/// Màn hình xác nhận đặt hàng
/// Áp dụng SOLID (SRP): Tách riêng logic chọn/nhập địa chỉ, validate dữ liệu và gửi đơn hàng
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  // Controllers dùng khi người dùng chưa có bất kỳ địa chỉ nào trong sổ địa chỉ
  late final TextEditingController _newReceiverNameController;
  late final TextEditingController _newPhoneController;
  late final TextEditingController _newAddressController;

  ShippingAddress? _selectedAddress;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _newReceiverNameController = TextEditingController();
    _newPhoneController = TextEditingController();
    _newAddressController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.read<AuthProvider>().user;
      final userId = user?.userId ?? 0;
      final ds = context.read<AddressLocalDataSource>();

      final defaultAddress = ds.getDefaultOrFirst(userId);
      if (defaultAddress != null) {
        _selectedAddress = defaultAddress;
      } else {
        // Tên người nhận mặc định lấy từ họ tên (fullName), KHÔNG dùng username
        _newReceiverNameController.text = user?.fullName ?? '';
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _newReceiverNameController.dispose();
    _newPhoneController.dispose();
    _newAddressController.dispose();
    super.dispose();
  }

  void _openAddressSelector(int userId, String? defaultFullName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddressSelectorSheet(
        userId: userId,
        selectedAddressId: _selectedAddress?.id,
        defaultReceiverName: defaultFullName,
        onSelect: (address) {
          setState(() => _selectedAddress = address);
        },
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    final userId = user?.userId ?? 0;
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final addressDs = context.read<AddressLocalDataSource>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    String receiverName;
    String phone;
    String addressText;

    if (_selectedAddress != null) {
      receiverName = _selectedAddress!.receiverName;
      phone = _selectedAddress!.phone;
      addressText = _selectedAddress!.address;
    } else {
      // Trường hợp chưa có địa chỉ, validate form nhập trực tiếp
      if (!_formKey.currentState!.validate()) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Vui lòng kiểm tra lại thông tin người nhận và địa chỉ'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      receiverName = _newReceiverNameController.text.trim();
      phone = _newPhoneController.text.trim();
      addressText = _newAddressController.text.trim();

      // Tự động lưu địa chỉ này vào sổ địa chỉ để sử dụng cho lần sau
      final newAddress = ShippingAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        receiverName: receiverName,
        phone: phone,
        address: addressText,
        isDefault: true,
      );
      await addressDs.saveAddress(userId, newAddress);
      setState(() => _selectedAddress = newAddress);
    }

    final params = PlaceOrderParams(
      items: cartProvider.cart.items,
      receiverName: receiverName,
      phone: phone,
      shippingAddress: addressText,
      note: _noteController.text.trim(),
    );

    final error = await orderProvider.placeOrder(params);

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
              navigator.popUntil((route) => route.isFirst);
              if (context.mounted) {
                context.read<BookProvider>().loadBooks(isAdmin: isAdmin);
              }
            },
            child: const Text('Xem đơn hàng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;
    final userId = user?.userId ?? 0;
    final cart = context.watch<CartProvider>().cart;
    final isPlacing =
        context.select<OrderProvider, bool>((orders) => orders.isPlacing);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Xác nhận đặt hàng')),
        body: const Center(
          child: Text('Giỏ hàng đang trống'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt hàng')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Thông tin nhận hàng (Địa chỉ, Số điện thoại, Họ tên người nhận)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Địa chỉ nhận hàng',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedAddress != null)
                        TextButton(
                          onPressed: () => _openAddressSelector(userId, user?.fullName),
                          child: const Text('Thay đổi'),
                        ),
                    ],
                  ),
                  const Divider(height: 16),

                  if (_selectedAddress != null) ...[
                    // Trường hợp 1: Đã có địa chỉ trong sổ địa chỉ
                    Row(
                      children: [
                        Text(
                          _selectedAddress!.receiverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _selectedAddress!.phone,
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (_selectedAddress!.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedAddress!.address,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                  ] else ...[
                    // Trường hợp 2: Chưa có địa chỉ nào -> Bắt buộc thêm mới ngay trên form
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bạn chưa có địa chỉ nhận hàng. Vui lòng nhập thông tin bên dưới để tiếp tục.',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Tên người nhận (Phải dùng họ tên, không dùng username)
                          TextFormField(
                            controller: _newReceiverNameController,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên người nhận *',
                              hintText: 'Ví dụ: Nguyễn Văn A',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Vui lòng nhập họ và tên người nhận';
                              }
                              if (text.length < 2 || text.length > 100) {
                                return 'Họ tên phải từ 2 đến 100 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Số điện thoại người nhận
                          TextFormField(
                            controller: _newPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại người nhận *',
                              hintText: 'Ví dụ: 0912345678',
                              prefixIcon: Icon(Icons.phone_outlined, size: 20),
                            ),
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              if (!PlaceOrderParams.vnPhoneRegex.hasMatch(text)) {
                                return 'SĐT gồm 10 chữ số (đầu 03, 05, 07, 08, 09)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Địa chỉ chi tiết
                          TextFormField(
                            controller: _newAddressController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Địa chỉ nhận hàng chi tiết *',
                              hintText: 'Số nhà, đường/phố, phường/xã, quận/huyện, tỉnh/TP',
                              prefixIcon: Icon(Icons.home_outlined, size: 20),
                            ),
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Vui lòng nhập địa chỉ nhận hàng';
                              }
                              if (text.length < 5 || text.length > 1000) {
                                return 'Địa chỉ phải từ 5 đến 1000 ký tự';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 2: Ghi chú đơn hàng (Tùy chọn)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Ghi chú đơn hàng',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Ghi chú cho người bán hoặc shipper (ví dụ: giao giờ hành chính, gọi trước khi đến...)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 3: Danh sách sản phẩm
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Danh sách sách đặt (${cart.totalQuantity})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  for (final item in cart.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.bookName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${CurrencyFormatter.vnd(item.price)} × ${item.quantity}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.vnd(item.subtotal),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 4: Tóm tắt thanh toán
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tạm tính'),
                      Text(CurrencyFormatter.vnd(cart.totalPrice)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Phí vận chuyển'),
                      Text(
                        'Miễn phí',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng thanh toán',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.vnd(cart.totalPrice),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: isPlacing ? null : () => _submitOrder(context),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isPlacing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Xác nhận đặt hàng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
