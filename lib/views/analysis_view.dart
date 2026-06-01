import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AnalysisView extends StatelessWidget {
  AnalysisView({super.key});

  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final transactions = args is List<TransactionModel> ? args : <TransactionModel>[];

    double income = 0;
    double expense = 0;

    final Map<Category, Color> categoryColors = {
      Category.alimentacao: const Color(0xFFFF9800),
      Category.transporte: const Color(0xFF2196F3),
      Category.lazer: const Color(0xFF9C27B0),
      Category.salario: const Color(0xFF4CAF50),
      Category.outros: const Color(0xFF424242),
    };

    final Map<Category, double> categoryData = {};

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.value;
      } else {
        expense += transaction.value;
      }

      categoryData[transaction.category] =
          (categoryData[transaction.category] ?? 0) + transaction.value;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Análise'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _card('Receitas', income, Colors.green),
                  const SizedBox(width: 10),
                  _card('Despesas', expense, Colors.red),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: categoryData.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(30),
                        child: Text('Sem dados para exibir no gráfico.'),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: categoryData.entries.map((entry) {
                                  return PieChartSectionData(
                                    value: entry.value,
                                    title: '',
                                    color: categoryColors[entry.key],
                                    radius: 70,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: categoryData.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: categoryColors[entry.key],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      entry.key.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _currency.format(entry.value),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (_, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: categoryColors[transaction.category]!.withOpacity(0.2),
                    child: Icon(Icons.category, color: categoryColors[transaction.category]),
                  ),
                  title: Text(transaction.title, style: const TextStyle(color: Colors.black)),
                  subtitle: Text(
                    transaction.category.label,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: Text(
                    _currency.format(transaction.value),
                    style: TextStyle(
                      color: transaction.isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 5),
            Text(
              _currency.format(value),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
