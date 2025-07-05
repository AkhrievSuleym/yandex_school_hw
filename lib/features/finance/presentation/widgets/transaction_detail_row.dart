import 'package:flutter/material.dart';

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onTap;
  final bool showArrow;

  const TransactionDetailRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.onTap,
    this.showArrow = true, // По умолчанию показываем стрелку
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(label, style: theme.textTheme.titleMedium),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child:
                            valueWidget ??
                            Text(
                              value ?? '',
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                      if (showArrow)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: theme.iconTheme.color?.withOpacity(0.6),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
