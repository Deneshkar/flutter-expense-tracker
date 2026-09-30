import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_form.dart';

/// Screen for editing an existing expense record.
class EditExpenseScreen extends StatelessWidget {
  final Expense expense;
  final ExpenseService? expenseService;

  const EditExpenseScreen({
    super.key,
    required this.expense,
    this.expenseService,
  });

  @override
  Widget build(BuildContext context) {
    final service = expenseService ?? ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
      ),
      body: ExpenseForm(
        initialExpense: expense,
        submitButtonText: 'Update Expense',
        onSave: (Expense updatedExpense) async {
          await service.updateExpense(updatedExpense);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Updated "${updatedExpense.title}" successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
