import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/home_screen.dart';
import 'package:spendly/screens/expenses_screen.dart';
import 'package:spendly/services/expense_service.dart';
import 'package:spendly/widgets/empty_state.dart';
import 'package:spendly/widgets/error_state.dart';
import 'package:spendly/widgets/loading_state.dart';

class MockStreamExpenseService extends ExpenseService {
  final Stream<List<Expense>> stream;
  int getExpensesCallCount = 0;

  MockStreamExpenseService(this.stream);

  @override
  Stream<List<Expense>> getExpenses() {
    getExpensesCallCount++;
    return stream;
  }
}

void main() {
  group('Step 14: Loading, Empty, and Error State Widgets', () {
    testWidgets('LoadingState renders spinner and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(message: 'Loading your expenses...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your expenses...'), findsOneWidget);
    });

    testWidgets('EmptyState renders title, description, icon, and button', (WidgetTester tester) async {
      bool buttonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'No expenses found',
              message: 'Add an expense to start tracking.',
              icon: Icons.receipt_long_outlined,
              buttonText: 'Add First Expense',
              onButtonPressed: () {
                buttonClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('No expenses found'), findsOneWidget);
      expect(find.text('Add an expense to start tracking.'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.text('Add First Expense'), findsOneWidget);

      await tester.tap(find.text('Add First Expense'));
      expect(buttonClicked, isTrue);
    });

    testWidgets('ErrorState renders error icon, message, and triggers onRetry', (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Failed to connect',
              message: 'Check your internet connection and try again.',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Failed to connect'), findsOneWidget);
      expect(find.text('Check your internet connection and try again.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });
  });

  group('Step 14: Screen State Integration Tests', () {
    testWidgets('HomeScreen displays LoadingState when waiting for expenses', (WidgetTester tester) async {
      final controller = StreamController<List<Expense>>();
      final mockService = MockStreamExpenseService(controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(expenseService: mockService),
        ),
      );

      // Immediately after initial pump, stream is waiting
      expect(find.byType(LoadingState), findsOneWidget);
      expect(find.text('Loading your expenses...'), findsOneWidget);

      await controller.close();
    });

    testWidgets('HomeScreen displays ErrorState on stream error and retry button works', (WidgetTester tester) async {
      final mockService = MockStreamExpenseService(
        Stream<List<Expense>>.error(Exception('Firestore network error')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Verify retry calls getExpenses again
      expect(mockService.getExpensesCallCount, equals(1));
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(mockService.getExpensesCallCount, equals(2));
    });

    testWidgets('ExpensesScreen displays LoadingState when waiting for expenses', (WidgetTester tester) async {
      final controller = StreamController<List<Expense>>();
      final mockService = MockStreamExpenseService(controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );

      expect(find.byType(LoadingState), findsOneWidget);
      expect(find.text('Loading your expenses...'), findsOneWidget);

      await controller.close();
    });

    testWidgets('ExpensesScreen displays ErrorState on stream error and retry works', (WidgetTester tester) async {
      final mockService = MockStreamExpenseService(
        Stream<List<Expense>>.error(Exception('Failed to load')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      expect(mockService.getExpensesCallCount, equals(1));
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(mockService.getExpensesCallCount, equals(2));
    });
  });
}
