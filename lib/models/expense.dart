import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a single expense record in Spendly.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converts a Firestore document map into a strongly-typed Expense object.
  factory Expense.fromMap(Map<String, dynamic> map, [String? docId]) {
    // Helper to safely parse dates whether stored as Timestamp, String, or null
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    // Helper to safely parse amount to double
    double parseAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return Expense(
      id: docId ?? map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: parseAmount(map['amount']),
      category: map['category']?.toString() ?? ExpenseCategory.other,
      date: parseDate(map['date']),
      note: map['note']?.toString() ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }

  /// Converts this Expense object into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this Expense with modified fields.
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Fixed expense categories with corresponding icons and colors.
class ExpenseCategory {
  static const String food = 'Food';
  static const String transport = 'Transport';
  static const String shopping = 'Shopping';
  static const String bills = 'Bills';
  static const String entertainment = 'Entertainment';
  static const String health = 'Health';
  static const String education = 'Education';
  static const String travel = 'Travel';
  static const String other = 'Other';

  /// List of all supported categories.
  static const List<String> all = [
    food,
    transport,
    shopping,
    bills,
    entertainment,
    health,
    education,
    travel,
    other,
  ];

  /// Returns the corresponding icon for a category.
  static IconData getIcon(String category) {
    switch (category) {
      case food:
        return Icons.restaurant_rounded;
      case transport:
        return Icons.directions_bus_rounded;
      case shopping:
        return Icons.shopping_bag_rounded;
      case bills:
        return Icons.receipt_long_rounded;
      case entertainment:
        return Icons.movie_rounded;
      case health:
        return Icons.medical_services_rounded;
      case education:
        return Icons.school_rounded;
      case travel:
        return Icons.flight_rounded;
      case other:
      default:
        return Icons.category_rounded;
    }
  }

  /// Returns a curated color for each category for chips and charts.
  static Color getColor(String category) {
    switch (category) {
      case food:
        return const Color(0xFFF97316); // Amber / Orange
      case transport:
        return const Color(0xFF0EA5E9); // Sky Blue
      case shopping:
        return const Color(0xFFEC4899); // Pink
      case bills:
        return const Color(0xFFEAB308); // Yellow
      case entertainment:
        return const Color(0xFF8B5CF6); // Purple
      case health:
        return const Color(0xFFEF4444); // Red
      case education:
        return const Color(0xFF10B981); // Emerald Green
      case travel:
        return const Color(0xFF06B6D4); // Cyan
      case other:
      default:
        return const Color(0xFF6B7280); // Neutral Slate
    }
  }
}
