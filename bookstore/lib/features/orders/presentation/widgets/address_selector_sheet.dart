import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/address_local_datasource.dart';
import '../../domain/entities/shipping_address.dart';
import 'address_form_dialog.dart';

/// Modal BottomSheet hiển thị danh sách địa chỉ nhận hàng và cho phép thay đổi / thêm mới
/// Áp dụng SOLID (SRP): Chịu trách nhiệm hiển thị và quản lý danh sách địa chỉ của người dùng
class AddressSelectorSheet extends StatefulWidget {
  const AddressSelectorSheet({
    super.key,
    required this.userId,
    this.selectedAddressId,
    required this.onSelect,
    this.defaultReceiverName,
  });

  final int userId;
  final String? selectedAddressId;
  final ValueChanged<ShippingAddress> onSelect;
  final String? defaultReceiverName;

  @override
  State<AddressSelectorSheet> createState() => _AddressSelectorSheetState();
}

class _AddressSelectorSheetState extends State<AddressSelectorSheet> {
  late List<ShippingAddress> _addresses;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedAddressId;
    _loadAddresses();
  }

  void _loadAddresses() {
    final ds = context.read<AddressLocalDataSource>();
    _addresses = ds.getAddresses(widget.userId);
    if (_selectedId == null && _addresses.isNotEmpty) {
      _selectedId = _addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => _addresses.first,
      ).id;
    }
  }

  Future<void> _addNewAddress() async {
    final newAddress = await showDialog<ShippingAddress>(
      context: context,
      builder: (_) => AddressFormDialog(
        defaultReceiverName: widget.defaultReceiverName,
      ),
    );

    if (newAddress != null && mounted) {
      final ds = context.read<AddressLocalDataSource>();
      await ds.saveAddress(widget.userId, newAddress);
      setState(() {
        _loadAddresses();
        _selectedId = newAddress.id;
      });
      widget.onSelect(newAddress);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _editAddress(ShippingAddress address) async {
    final updated = await showDialog<ShippingAddress>(
      context: context,
      builder: (_) => AddressFormDialog(initialAddress: address),
    );

    if (updated != null && mounted) {
      final ds = context.read<AddressLocalDataSource>();
      await ds.saveAddress(widget.userId, updated);
      setState(() {
        _loadAddresses();
        if (_selectedId == updated.id) {
          widget.onSelect(updated);
        }
      });
    }
  }

  Future<void> _deleteAddress(ShippingAddress address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa địa chỉ của "${address.receiverName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ds = context.read<AddressLocalDataSource>();
      await ds.deleteAddress(widget.userId, address.id);
      setState(() {
        _loadAddresses();
        if (_selectedId == address.id && _addresses.isNotEmpty) {
          final nextDefault = ds.getDefaultOrFirst(widget.userId);
          if (nextDefault != null) {
            _selectedId = nextDefault.id;
            widget.onSelect(nextDefault);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh tiêu đề kéo
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Địa chỉ nhận hàng',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addNewAddress,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                ),
              ],
            ),
            const Divider(height: 16),

            if (_addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bạn chưa có địa chỉ nhận hàng nào',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _addNewAddress,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm địa chỉ nhận hàng ngay'),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _addresses[index];
                    final isSelected = _selectedId == item.id;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedId = item.id);
                        widget.onSelect(item);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                            width: isSelected ? 1.8 : 1,
                          ),
                          color: isSelected
                              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 8),
                              child: Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.receiverName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.phone,
                                        style: TextStyle(
                                          color: theme.colorScheme.outline,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (item.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Text(
                                            'Mặc định',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.address,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              padding: EdgeInsets.zero,
                              onSelected: (action) {
                                if (action == 'edit') {
                                  _editAddress(item);
                                } else if (action == 'delete') {
                                  _deleteAddress(item);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Chỉnh sửa'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text('Xóa', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
