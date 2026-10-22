import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    this.maxStock,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final int? maxStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMaxReached = maxStock != null && item.quantity >= maxStock!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.bookName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.vnd(item.price),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                      if (maxStock != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(Kho: $maxStock)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isMaxReached
                                ? Colors.orange.shade800
                                : theme.colorScheme.outline,
                            fontWeight: isMaxReached
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Giảm',
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrease,
            ),
            Text('${item.quantity}', style: theme.textTheme.titleMedium),
            IconButton(
              tooltip: isMaxReached
                  ? 'Đã đạt giới hạn tồn kho ($maxStock cuốn)'
                  : 'Tăng',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: isMaxReached ? null : onIncrease,
            ),
            IconButton(
              tooltip: 'Xóa',
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
