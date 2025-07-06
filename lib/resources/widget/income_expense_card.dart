import 'package:flutter/material.dart';

class IncomeExpenseCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData iconData;
  final Color iconColor;
  final Color backgroundColor;

  const IncomeExpenseCard({
    super.key,
    required this.title,
    required this.amount,
    required this.iconData,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        // ... (kode styling container sama seperti sebelumnya) ...
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount, // Amount ini akan datang dari state induk
              style: textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
