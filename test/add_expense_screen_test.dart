import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/widgets/expense_form.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('ExpenseForm & Validation Tests', () {
    testWidgets('Empty title and amount fail validation', (WidgetTester tester) async {
      bool saved = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ExpenseForm(
            onSave: (expense) async {
              saved = true;
            },
          ),
        ),
      );

      // Tap Save without entering any values
      await tester.tap(find.text('Save Expense'));
      await tester.pump();

      // Expect validation error messages
      expect(find.text('Please enter an expense title'), findsOneWidget);
      expect(find.text('Please enter an amount'), findsOneWidget);
      expect(saved, isFalse);
    });

    testWidgets('Amount <= 0 fails validation', (WidgetTester tester) async {
      bool saved = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ExpenseForm(
            onSave: (expense) async {
              saved = true;
            },
          ),
        ),
      );

      // Enter valid title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Expense Title *'),
        'Groceries',
      );

      // Enter 0 amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (Rs.) *'),
        '0',
      );

      // Tap Save
      await tester.tap(find.text('Save Expense'));
      await tester.pump();

      expect(find.text('Amount must be greater than 0'), findsOneWidget);
      expect(saved, isFalse);
    });

    testWidgets('Valid inputs pass validation and invoke onSave', (WidgetTester tester) async {
      Expense? submittedExpense;

      await tester.pumpWidget(
        buildTestableWidget(
          ExpenseForm(
            onSave: (expense) async {
              submittedExpense = expense;
            },
          ),
        ),
      );

      // Enter valid title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Expense Title *'),
        'Coffee and Snack',
      );

      // Enter valid amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (Rs.) *'),
        '450.50',
      );

      // Tap Save
      await tester.tap(find.text('Save Expense'));
      await tester.pump();

      expect(submittedExpense, isNotNull);
      expect(submittedExpense!.title, 'Coffee and Snack');
      expect(submittedExpense!.amount, 450.50);
      expect(submittedExpense!.category, ExpenseCategory.food);
    });
  });
}
