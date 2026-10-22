import 'package:flutter/material.dart';

import '../../domain/entities/book_filter_params.dart';

/// Hộp thoại kết hợp tất cả các bộ lọc (Chủ đề, Khoảng giá, Trạng thái)
/// Áp dụng SOLID (SRP): Chịu trách nhiệm riêng về giao diện lọc và validate dữ liệu bộ lọc trước khi gửi API.
class BookFilterSheet extends StatefulWidget {
  const BookFilterSheet({
    super.key,
    required this.currentParams,
    required this.isAdmin,
    required this.availableTags,
    required this.onApply,
    required this.onReset,
  });

  final BookFilterParams currentParams;
  final bool isAdmin;
  final List<String> availableTags;
  final ValueChanged<BookFilterParams> onApply;
  final VoidCallback onReset;

  @override
  State<BookFilterSheet> createState() => _BookFilterSheetState();
}

class _BookFilterSheetState extends State<BookFilterSheet> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late String _status;
  late String _selectedTag;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.currentParams.minPrice != null
          ? widget.currentParams.minPrice!.toStringAsFixed(0)
          : '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentParams.maxPrice != null
          ? widget.currentParams.maxPrice!.toStringAsFixed(0)
          : '',
    );
    // Nếu là khách hàng bình thường: luôn cố định là ACTIVE (không thấy sách hết hàng)
    _status = widget.isAdmin
        ? (widget.currentParams.status ?? 'ALL')
        : 'ACTIVE';
    _selectedTag = widget.currentParams.tag ?? 'Tất cả';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _validateAndApply() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();

    double? minPrice;
    double? maxPrice;

    if (minText.isNotEmpty) {
      minPrice = double.tryParse(minText);
      if (minPrice == null || minPrice < 0) {
        setState(() => _errorMessage = 'Giá tối thiểu phải là số hợp lệ >= 0');
        return;
      }
    }

    if (maxText.isNotEmpty) {
      maxPrice = double.tryParse(maxText);
      if (maxPrice == null || maxPrice < 0) {
        setState(() => _errorMessage = 'Giá tối đa phải là số hợp lệ >= 0');
        return;
      }
    }

    // Validate quy tắc backend: minPrice không được lớn hơn maxPrice
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      setState(
        () => _errorMessage = 'Giá tối thiểu không được lớn hơn giá tối đa',
      );
      return;
    }

    setState(() => _errorMessage = null);

    final finalStatus = widget.isAdmin ? _status : 'ACTIVE';

    final newParams = widget.currentParams.copyWith(
      tag: _selectedTag,
      minPrice: minPrice,
      maxPrice: maxPrice,
      status: finalStatus,
      clearMinPrice: minPrice == null,
      clearMaxPrice: maxPrice == null,
      clearStatus: finalStatus == 'ALL',
      clearTag: _selectedTag == 'Tất cả',
    );

    widget.onApply(newParams);
    Navigator.of(context).pop();
  }

  void _handleReset() {
    _minPriceController.clear();
    _maxPriceController.clear();
    setState(() {
      _selectedTag = 'Tất cả';
      _status = widget.isAdmin ? 'ALL' : 'ACTIVE';
      _errorMessage = null;
    });
    widget.onReset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _handleReset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Đặt lại'),
                  ),
                ],
              ),
              const Divider(height: 16),

              // 1. Lọc theo Chủ đề / Tag
              if (widget.availableTags.isNotEmpty) ...[
                Text(
                  'Chủ đề / Phân loại',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final tag in widget.availableTags)
                      ChoiceChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedTag = tag);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // 2. Lọc theo trạng thái (Chỉ dành cho Quản trị viên)
              if (widget.isAdmin) ...[
                Text(
                  'Trạng thái mở bán',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: _status == 'ALL' || _status.isEmpty,
                      onSelected: (selected) {
                        if (selected) setState(() => _status = 'ALL');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Đang mở bán'),
                      selected: _status == 'ACTIVE',
                      onSelected: (selected) {
                        if (selected) setState(() => _status = 'ACTIVE');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Dừng bán'),
                      selected: _status == 'INACTIVE',
                      onSelected: (selected) {
                        if (selected) setState(() => _status = 'INACTIVE');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // 3. Lọc theo khoảng giá
              Text(
                'Khoảng giá (VNĐ)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Từ giá',
                        hintText: '0',
                        suffixText: 'đ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '—',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Đến giá',
                        hintText: '500.000',
                        suffixText: 'đ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Thông báo lỗi validate
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Nút Áp dụng
              FilledButton(
                onPressed: _validateAndApply,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Áp dụng bộ lọc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
