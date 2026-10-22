import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../logic/checkout_logic.dart';
import '../providers/order_provider.dart';

/// Màn hình xác nhận đặt hàng (Pure UI - SOLID SRP)
/// Toàn bộ logic kiểm tra tồn kho, quản lý form, điều hướng và gửi đơn
/// được ủy quyền cho [CheckoutLogic].
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final CheckoutLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = CheckoutLogic();
    _logic.addListener(_onLogicChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logic.validateAndAdjustCart(context, showModalIfChanged: true);
      }
    });
  }

  void _onLogicChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _logic.init(context);
  }

  @override
  void dispose() {
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    super.dispose();
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

    final selectedAddress = _logic.selectedAddress;

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
                          Icon(
                            Icons.location_on_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Địa chỉ nhận hàng',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (selectedAddress != null)
                        TextButton(
                          onPressed: () => _logic.openAddressSelector(
                            context,
                            userId,
                            user?.fullName,
                          ),
                          child: const Text('Thay đổi'),
                        ),
                    ],
                  ),
                  const Divider(height: 16),

                  if (selectedAddress != null) ...[
                    // Trường hợp 1: Đã có địa chỉ trong sổ địa chỉ
                    Row(
                      children: [
                        Text(
                          selectedAddress.receiverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedAddress.phone,
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (selectedAddress.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
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
                      selectedAddress.address,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.85),
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
                        border: Border.all(
                          color:
                              Colors.amber.shade700.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade900,
                            size: 20,
                          ),
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
                      key: _logic.formKey,
                      child: Column(
                        children: [
                          // Tên người nhận
                          TextFormField(
                            controller: _logic.newReceiverNameController,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên người nhận *',
                              hintText: 'Ví dụ: Nguyễn Văn A',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                            validator: _logic.validateReceiverName,
                          ),
                          const SizedBox(height: 10),

                          // Số điện thoại người nhận
                          TextFormField(
                            controller: _logic.newPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại người nhận *',
                              hintText: 'Ví dụ: 0912345678',
                              prefixIcon: Icon(Icons.phone_outlined, size: 20),
                            ),
                            validator: _logic.validatePhone,
                          ),
                          const SizedBox(height: 10),

                          // Địa chỉ chi tiết
                          TextFormField(
                            controller: _logic.newAddressController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Địa chỉ nhận hàng chi tiết *',
                              hintText:
                                  'Số nhà, đường/phố, phường/xã, quận/huyện, tỉnh/TP',
                              prefixIcon: Icon(Icons.home_outlined, size: 20),
                            ),
                            validator: _logic.validateAddress,
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
                      Icon(
                        Icons.edit_note_outlined,
                        color: theme.colorScheme.primary,
                      ),
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
                    controller: _logic.noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText:
                          'Ghi chú cho người bán hoặc shipper (ví dụ: giao giờ hành chính, gọi trước khi đến...)',
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
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: theme.colorScheme.primary,
                      ),
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
            onPressed: (isPlacing || cart.isEmpty)
                ? null
                : () => _logic.submitOrder(context),
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
