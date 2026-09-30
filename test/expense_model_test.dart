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

    test('ExpenseCategory lists all required categories', () {
      expect(ExpenseCategory.all.length, 9);
      expect(ExpenseCategory.all.contains('Food'), isTrue);
      expect(ExpenseCategory.all.contains('Transport'), isTrue);
      expect(ExpenseCategory.all.contains('Shopping'), isTrue);
      expect(ExpenseCategory.all.contains('Bills'), isTrue);
      expect(ExpenseCategory.all.contains('Entertainment'), isTrue);
      expect(ExpenseCategory.all.contains('Health'), isTrue);
      expect(ExpenseCategory.all.contains('Education'), isTrue);
      expect(ExpenseCategory.all.contains('Travel'), isTrue);
      expect(ExpenseCategory.all.contains('Other'), isTrue);
    });
  });
}
