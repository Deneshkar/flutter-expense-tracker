import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

/// A clean, modern card widget that displays details for a single expense.
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// Formats amount cleanly (e.g. Rs. 850 or Rs. 1,250.50).
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.##');
    return 'Rs. ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = ExpenseCategory.getColor(expense.category);
    final categoryIcon = ExpenseCategory.getIcon(expense.category);
    final formattedDate = DateFormat('dd MMM yyyy').format(expense.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Category Icon with colored background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title, Category, and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          expense.category,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount & Action Menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatAmount(expense.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (expense.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),

              // Optional edit/delete popup menu
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
