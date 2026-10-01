import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/expenses_screen.dart';
import 'package:spendly/screens/home_screen.dart';
import 'package:spendly/services/expense_service.dart';
import 'package:spendly/widgets/category_chart.dart';
import 'package:spendly/widgets/expense_card.dart';
import 'package:spendly/widgets/expense_form.dart';

class MockResponsivenessService extends ExpenseService {
  final List<Expense> expenses;

  MockResponsivenessService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }
}

void main() {
  group('Responsiveness & Overflow Prevention Tests', () {
    late ExpenseService service;

    setUp(() {
      service = MockResponsivenessService([
        Expense(
          id: 'exp-long-1',
          title: 'Very Extremely Long Expense Title That Could Wrap Across Multiple Lines In A Mobile App Layout',
          amount: 12500000.50,
          category: ExpenseCategory.shopping,
          date: DateTime.now(),
          note: 'This is an exceptionally detailed note describing a high-value transaction with extra notes and tags.',
          createdAt: DateTime.now(),
        ),
        Expense(
          id: 'exp-long-2',
          title: 'Groceries at Supermarket',
          amount: 8500.0,
          category: ExpenseCategory.food,
          date: DateTime.now(),
          note: 'Milk, Eggs, Bread',
          createdAt: DateTime.now(),
        ),
      ]);
    });

    testWidgets('HomeScreen renders on narrow device (320x568) without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(expenseService: service),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Scroll down to reveal recent expense cards and verify no overflow
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ExpensesScreen renders on narrow device (320x568) without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: service),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpensesScreen), findsOneWidget);
      expect(find.byType(ExpenseCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('ExpenseForm renders on tablet screen (800x1280) constrained within maxWidth', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseForm(
              onSave: (_) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseForm), findsOneWidget);
      expect(find.byType(ConstrainedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CategoryChart renders large numbers on narrow device without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CategoryChart(
                categoryTotals: const {
                  ExpenseCategory.shopping: 99999999.00,
                  ExpenseCategory.food: 5500000.00,
                },
                totalSpent: 105499999.00,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
