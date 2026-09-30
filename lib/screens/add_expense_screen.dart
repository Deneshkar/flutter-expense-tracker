import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_form.dart';

/// Screen for adding a new expense.
class AddExpenseScreen extends StatelessWidget {
  final ExpenseService? expenseService;

  const AddExpenseScreen({super.key, this.expenseService});

  @override
  Widget build(BuildContext context) {
    final service = expenseService ?? ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: ExpenseForm(
        submitButtonText: 'Save Expense',
        onSave: (Expense expense) async {
          await service.addExpense(expense);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added "${expense.title}" successfully'),
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
