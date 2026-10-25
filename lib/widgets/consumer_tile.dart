import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/saved_consumer.dart';

class ConsumerTile extends StatelessWidget {
  const ConsumerTile({
    super.key,
    required this.consumer,
    required this.onTap,
    required this.onRemove,
  });

  final SavedConsumer consumer;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasLast =
        consumer.lastAmount != null && consumer.lastAmount!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.tint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: cs.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consumer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'SNGPL  •  No: ${consumer.number}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      if (hasLast) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.tint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Rs ${consumer.lastAmount}  •  Due ${consumer.lastDueDate ?? ''}',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE05A5A),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurface, size: 26),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
