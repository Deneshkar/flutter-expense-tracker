import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/edit_expense_screen.dart';
import 'package:spendly/services/expense_service.dart';

class MockEditExpenseService extends ExpenseService {
  Expense? updatedExpense;

  @override
  Future<void> updateExpense(Expense expense) async {
    updatedExpense = expense;
  }
}

void main() {
  group('EditExpenseScreen Tests', () {
    final existingExpense = Expense(
      id: 'doc_123',
      title: 'Original Title',
      amount: 500.0,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 9, 14),
      note: 'Original Note',
    );

    testWidgets('Pre-fills existing expense values in form', (WidgetTester tester) async {
      final mockService = MockEditExpenseService();

      await tester.pumpWidget(
        MaterialApp(
          home: EditExpenseScreen(
            expense: existingExpense,
            expenseService: mockService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check pre-filled values
      expect(find.text('Original Title'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Original Note'), findsOneWidget);
      expect(find.text('Update Expense'), findsOneWidget);
    });

    testWidgets('Updates expense and submits modified data to updateExpense', (WidgetTester tester) async {
      final mockService = MockEditExpenseService();

      await tester.pumpWidget(
        MaterialApp(
          home: EditExpenseScreen(
            expense: existingExpense,
            expenseService: mockService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Modify title and amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Expense Title *'),
        'Updated Taxi Ride',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (Rs.) *'),
        '750',
      );

      // Tap Update Expense
      await tester.tap(find.text('Update Expense'));
      await tester.pumpAndSettle();

      // Verify service received updated model with same id
      expect(mockService.updatedExpense, isNotNull);
      expect(mockService.updatedExpense!.id, 'doc_123');
      expect(mockService.updatedExpense!.title, 'Updated Taxi Ride');
      expect(mockService.updatedExpense!.amount, 750.0);
      expect(mockService.updatedExpense!.category, ExpenseCategory.transport);
    });
  });
}
