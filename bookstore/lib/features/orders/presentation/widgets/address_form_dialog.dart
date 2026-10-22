import 'package:flutter/material.dart';

import '../../domain/entities/place_order_params.dart';
import '../../domain/entities/shipping_address.dart';

/// Hộp thoại thêm mới hoặc chỉnh sửa địa chỉ giao hàng
/// Áp dụng SOLID (SRP): Chịu trách nhiệm riêng về nhập liệu và xác thực thông tin địa chỉ
class AddressFormDialog extends StatefulWidget {
  const AddressFormDialog({
    super.key,
    this.initialAddress,
    this.defaultReceiverName,
  });

  final ShippingAddress? initialAddress;
  final String? defaultReceiverName;

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress;
    _nameController = TextEditingController(
      text: address?.receiverName ?? widget.defaultReceiverName ?? '',
    );
    _phoneController = TextEditingController(
      text: address?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: address?.address ?? '',
    );
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.initialAddress?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final result = ShippingAddress(
      id: id,
      receiverName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      isDefault: _isDefault,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialAddress != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Sửa địa chỉ nhận hàng' : 'Thêm địa chỉ mới',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Họ tên người nhận (Bắt buộc dùng họ tên, không dùng username)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên người nhận *',
                    hintText: 'Ví dụ: Nguyễn Văn A',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Vui lòng nhập họ và tên người nhận';
                    }
                    if (trimmed.length < 2 || trimmed.length > 100) {
                      return 'Họ tên phải từ 2 đến 100 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Số điện thoại (Validate 10 số chuẩn VN)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại *',
                    hintText: 'Ví dụ: 0912345678',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!PlaceOrderParams.vnPhoneRegex.hasMatch(trimmed)) {
                      return 'SĐT gồm 10 chữ số (đầu 03, 05, 07, 08, 09)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Địa chỉ giao hàng
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ nhận hàng chi tiết *',
                    hintText: 'Số nhà, ngõ/đường, phường/xã, quận/huyện, tỉnh/thành',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Vui lòng nhập địa chỉ nhận hàng';
                    }
                    if (trimmed.length < 5 || trimmed.length > 1000) {
                      return 'Địa chỉ phải từ 5 đến 1000 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Đặt làm mặc định
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: const Text('Đặt làm địa chỉ mặc định', style: TextStyle(fontSize: 13.5)),
                  value: _isDefault,
                  onChanged: (val) => setState(() => _isDefault = val ?? false),
                ),
                const SizedBox(height: 16),

                // Nút lưu
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Cập nhật địa chỉ' : 'Lưu địa chỉ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
