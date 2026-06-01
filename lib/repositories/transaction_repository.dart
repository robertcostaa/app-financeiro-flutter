import '../core/database/app_database.dart';
import '../models/transaction_model.dart';
import 'firestore_transaction_repository.dart';

class TransactionRepository {
  final FirestoreTransactionRepository _firestoreRepository =
      FirestoreTransactionRepository();

  Future<List<TransactionModel>> getTransactionsByUser(int userId) async {
    final db = await AppDatabase.instance.database;

    try {
      final remoteTransactions =
          await _firestoreRepository.getRemoteTransactions(userId);

      if (remoteTransactions.isNotEmpty) {
        await db.delete(
          'transactions',
          where: 'userId = ?',
          whereArgs: [userId],
        );

        for (final transaction in remoteTransactions) {
          await db.insert('transactions', transaction.toMap());
        }
      }
    } catch (_) {}

    final result = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );

    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await AppDatabase.instance.database;

    String? firebaseId;

    try {
      firebaseId = await _firestoreRepository.addTransaction(transaction);
    } catch (_) {}

    final transactionToSave = transaction.copyWith(firebaseId: firebaseId);

    return db.insert(
      'transactions',
      transactionToSave.toMap(),
    );
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await AppDatabase.instance.database;

    try {
      await _firestoreRepository.updateTransaction(transaction);
    } catch (_) {}

    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [
        transaction.id,
        transaction.userId,
      ],
    );
  }

  Future<int> deleteTransaction(TransactionModel transaction) async {
    final db = await AppDatabase.instance.database;

    try {
      await _firestoreRepository.deleteTransaction(transaction);
    } catch (_) {}

    return db.delete(
      'transactions',
      where: 'id = ? AND userId = ?',
      whereArgs: [
        transaction.id,
        transaction.userId,
      ],
    );
  }
}