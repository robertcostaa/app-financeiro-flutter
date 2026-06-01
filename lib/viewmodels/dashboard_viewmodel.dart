import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  double get balance => transactions.fold(
        0,
        (sum, transaction) => transaction.isIncome
            ? sum + transaction.value
            : sum - transaction.value,
      );

  double get totalIncome => transactions
      .where((transaction) => transaction.isIncome)
      .fold(0, (sum, transaction) => sum + transaction.value);

  double get totalExpense => transactions
      .where((transaction) => !transaction.isIncome)
      .fold(0, (sum, transaction) => sum + transaction.value);

  List<TransactionModel> get thisMonthTransactions {
    final now = DateTime.now();

    return transactions
        .where(
          (transaction) =>
              transaction.date.month == now.month &&
              transaction.date.year == now.year,
        )
        .toList();
  }

  Future<void> loadData(int userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      transactions = await _repository.getTransactionsByUser(userId);
    } catch (e) {
      errorMessage =
          'Erro ao carregar dados. Verifique sua conexão. Usando dados locais.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
    await loadData(transaction.userId);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;

    await _repository.updateTransaction(transaction);
    await loadData(transaction.userId);
  }

  Future<void> removeTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;

    await _repository.deleteTransaction(transaction);
    await loadData(transaction.userId);
  }

  void clear() {
    transactions = [];
    errorMessage = null;
    notifyListeners();
  }
}