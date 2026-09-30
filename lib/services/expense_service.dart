import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

/// A simple, beginner-friendly service to perform CRUD operations
/// on Cloud Firestore for the 'expenses' collection.
class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to the 'expenses' collection in Firestore.
  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection('expenses');

  /// Stream of all expenses sorted by date in descending order (latest first).
  ///
  /// Using a Stream enables real-time updates: whenever an expense is added,
  /// edited, or deleted in Firestore, the UI will automatically update.
  Stream<List<Expense>> getExpenses() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Adds a new expense document to Firestore.
  ///
  /// Generates a unique document ID and saves the expense data.
  Future<void> addExpense(Expense expense) async {
    // Generate a new document reference with a unique ID
    final docRef = _expensesRef.doc();
    // Ensure the expense carries the same ID as the Firestore document
    final newExpense = expense.copyWith(id: docRef.id);
    await docRef.set(newExpense.toMap());
  }

  /// Updates an existing expense document in Firestore.
  Future<void> updateExpense(Expense expense) async {
    if (expense.id.isEmpty) {
      throw ArgumentError('Cannot update an expense without a valid ID.');
    }
    await _expensesRef.doc(expense.id).update(expense.toMap());
  }

  /// Deletes an expense document from Firestore using its document ID.
  Future<void> deleteExpense(String expenseId) async {
    if (expenseId.isEmpty) {
      throw ArgumentError('Cannot delete an expense without a valid ID.');
    }
    await _expensesRef.doc(expenseId).delete();
  }
}
