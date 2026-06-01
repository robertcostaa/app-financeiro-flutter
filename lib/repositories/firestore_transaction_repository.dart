import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';

class FirestoreTransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _uid;

    if (uid == null) {
      return null;
    }

    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  Future<String?> addTransaction(TransactionModel transaction) async {
    final collection = _collection;

    if (collection == null) {
      return null;
    }

    final doc = await collection.add(transaction.toFirebaseMap());
    return doc.id;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final collection = _collection;

    if (collection == null || transaction.firebaseId == null) {
      return;
    }

    await collection
        .doc(transaction.firebaseId)
        .set(transaction.toFirebaseMap(), SetOptions(merge: true));
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    final collection = _collection;

    if (collection == null || transaction.firebaseId == null) {
      return;
    }

    await collection.doc(transaction.firebaseId).delete();
  }

  Future<List<TransactionModel>> getRemoteTransactions(int userId) async {
    final collection = _collection;

    if (collection == null) {
      return [];
    }

    final snapshot = await collection.orderBy('date', descending: true).get();

    return snapshot.docs.map((doc) {
      return TransactionModel.fromFirebaseMap(doc.data(), doc.id);
    }).toList();
  }
}
