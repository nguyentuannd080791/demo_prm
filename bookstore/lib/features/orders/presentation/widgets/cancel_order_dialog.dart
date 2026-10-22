import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog({super.key, required this.orderId});

  final int orderId;

  static Future<bool?> show(BuildContext context, int orderId) {
    return showDialog<bool>(
      context: context,
      builder: (_) => CancelOrderDialog(orderId: orderId),
    );
  }

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final error = await context.read<OrderProvider>().cancelOrder(
          widget.orderId,
          reason: _reasonController.text.trim(),
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _submitting = false;
        _errorMessage = error;
      });
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text('Hủy đơn hàng #${widget.orderId}')),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn có chắc chắn muốn hủy đơn hàng này? Sau khi hủy, đơn hàng không thể phục hồi.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLength: 2000,
                maxLines: 3,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: 'Lý do hủy đơn (tùy chọn)',
                  hintText: 'VD: Thay đổi địa chỉ, đặt nhầm sách...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val != null && val.trim().length > 2000) {
                    return 'Lý do không được vượt quá 2000 ký tự';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Đóng'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Xác nhận hủy'),
        ),
      ],
    );
  }
}
