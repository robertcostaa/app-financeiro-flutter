import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../views/add_transaction_modal.dart';
import '../widgets/news_section.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _searchController = TextEditingController();

  Category? _selectedCategory;

  final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final _date = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = context.read<AuthViewModel>().currentUser;

      if (user?.id != null) {
        context.read<DashboardViewModel>().loadData(user!.id!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTransactionModal({TransactionModel? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) => AddTransactionModal(
        transaction: transaction,
      ),
    );
  }

  Future<void> _confirmDelete(TransactionModel transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir transação'),
          content: Text('Deseja excluir "${transaction.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await context.read<DashboardViewModel>().removeTransaction(transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<DashboardViewModel>();
    final user = auth.currentUser;

    if (user == null) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.auth);
        }
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filtered = vm.transactions.where((transaction) {
      final matchesSearch = transaction.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      final matchesCategory = _selectedCategory == null ||
          transaction.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Olá, ${user.name.split(' ').first}'),
        actions: [
          IconButton(
            tooltip: 'Análise',
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.analysis,
                arguments: vm.transactions,
              );
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              context.read<DashboardViewModel>().clear();

              if (context.mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.auth,
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openTransactionModal();
        },
        child: const Icon(Icons.add),
      ).animate().scale(),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () {
                return vm.loadData(user.id!);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _balanceCard(vm),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: 'Entradas',
                          value: vm.totalIncome,
                          color: Colors.green,
                          icon: Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: 'Saídas',
                          value: vm.totalExpense,
                          color: Colors.red,
                          icon: Icons.arrow_upward,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const NewsSection(),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por título',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Category?>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por categoria',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<Category?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...Category.values.map(
                        (category) {
                          return DropdownMenuItem<Category?>(
                            value: category,
                            child: Text(category.label),
                          );
                        },
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          'Nenhuma transação encontrada.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filtered.map(
                      (transaction) {
                        return _transactionTile(transaction);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _balanceCard(DashboardViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo total',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currency.format(vm.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _summaryCard({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currency.format(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(TransactionModel transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isIncome
              ? Colors.green.withOpacity(0.12)
              : Colors.red.withOpacity(0.12),
          child: Icon(
            transaction.isIncome ? Icons.trending_up : Icons.trending_down,
            color: transaction.isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category.label} • ${_date.format(transaction.date)}',
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _currency.format(transaction.value),
              style: TextStyle(
                color: transaction.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _openTransactionModal(
                    transaction: transaction,
                  );
                } else if (value == 'delete') {
                  _confirmDelete(transaction);
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
