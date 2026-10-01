import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    final testDate = DateTime(2026, 9, 15, 10, 30);
    final testCreatedAt = DateTime(2026, 9, 15, 10, 35);

    test('toMap converts Expense instance to a valid Map', () {
      final expense = Expense(
        id: 'exp_123',
        title: 'Grocery Shopping',
        amount: 2500.50,
        category: ExpenseCategory.food,
        date: testDate,
        note: 'Supermarket weekly grocery',
        createdAt: testCreatedAt,
      );

      final map = expense.toMap();

      expect(map['id'], 'exp_123');
      expect(map['title'], 'Grocery Shopping');
      expect(map['amount'], 2500.50);
      expect(map['category'], 'Food');
      expect(map['note'], 'Supermarket weekly grocery');
      expect(map['date'], isA<Timestamp>());
      expect((map['date'] as Timestamp).toDate(), testDate);
      expect((map['createdAt'] as Timestamp).toDate(), testCreatedAt);
    });

    test('fromMap creates valid Expense instance from Map and docId', () {
      final map = {
        'title': 'Bus Ticket',
        'amount': 150,
        'category': 'Transport',
        'date': Timestamp.fromDate(testDate),
        'note': 'City transit',
        'createdAt': Timestamp.fromDate(testCreatedAt),
      };

      final expense = Expense.fromMap(map, 'doc_456');

      expect(expense.id, 'doc_456');
      expect(expense.title, 'Bus Ticket');
      expect(expense.amount, 150.0);
      expect(expense.category, 'Transport');
      expect(expense.date, testDate);
      expect(expense.note, 'City transit');
      expect(expense.createdAt, testCreatedAt);
    });

    test('copyWith updates fields correctly', () {
      final original = Expense(
        id: '1',
        title: 'Coffee',
        amount: 350.0,
        category: ExpenseCategory.food,
        date: testDate,
      );

      final updated = original.copyWith(amount: 400.0, title: 'Iced Latte');

      expect(updated.id, '1');
      expect(updated.title, 'Iced Latte');
      expect(updated.amount, 400.0);
      expect(updated.category, ExpenseCategory.food);
    });

    test('ExpenseCategory returns appropriate icons and colors for each category and fallback', () {
      for (final cat in ExpenseCategory.all) {
        expect(ExpenseCategory.getIcon(cat), isNotNull);
        expect(ExpenseCategory.getColor(cat), isNotNull);
      }

      // Fallback for unknown category
      expect(ExpenseCategory.getIcon('UnknownCategory'), ExpenseCategory.getIcon(ExpenseCategory.other));
      expect(ExpenseCategory.getColor('UnknownCategory'), ExpenseCategory.getColor(ExpenseCategory.other));
    });

    test('copyWith updates date, category, and note', () {
      final original = Expense(
        id: '1',
        title: 'Lunch',
        amount: 500,
        category: ExpenseCategory.food,
        date: testDate,
        note: 'Old note',
      );

      final newDate = DateTime(2026, 10, 1);
      final updated = original.copyWith(
        id: '2',
        category: ExpenseCategory.travel,
        date: newDate,
        note: 'New note',
        createdAt: newDate,
      );

      expect(updated.id, '2');
      expect(updated.category, ExpenseCategory.travel);
      expect(updated.date, newDate);
      expect(updated.note, 'New note');
      expect(updated.createdAt, newDate);
    });

    test('fromMap gracefully handles null note and int amount', () {
      final map = {
        'title': 'Train',
        'amount': 250, // int
        'category': 'Travel',
        'date': Timestamp.fromDate(testDate),
        // note is omitted
      };

      final expense = Expense.fromMap(map, 'doc_999');
      expect(expense.amount, 250.0);
      expect(expense.note, '');
    });
  });
}
