import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../providers/app_providers.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionModal({
    super.key,
    this.transaction,
  });

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _valueController = TextEditingController();

  bool _isIncome = true;
  Category _selectedCategory = Category.outros;
  DateTime _selectedDate = DateTime.now();

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    if (transaction != null) {
      _titleController.text = transaction.title;
      _valueController.text = transaction.value.toStringAsFixed(2);
      _isIncome = transaction.isIncome;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(authProvider).currentUser;

    if (user?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não encontrado. Faça login novamente.'),
        ),
      );
      return;
    }

    final value = double.parse(
      _valueController.text.replaceAll(',', '.'),
    );

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      firebaseId: widget.transaction?.firebaseId,
      userId: user!.id!,
      title: _titleController.text.trim(),
      value: value,
      isIncome: _isIncome,
      category: _selectedCategory,
      date: _selectedDate,
    );

    if (_isEditing) {
      await ref.read(dashboardProvider).updateTransaction(transaction);
    } else {
      await ref.read(dashboardProvider).addTransaction(transaction);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Editar transação' : 'Nova transação',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o valor.';
                  }

                  final parsed = double.tryParse(
                    value.replaceAll(',', '.'),
                  );

                  if (parsed == null || parsed <= 0) {
                    return 'Informe um valor numérico válido.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: Category.values.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Entrada'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Saída'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_isIncome},
                onSelectionChanged: (value) {
                  setState(() {
                    _isIncome = value.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Data: ${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Salvar alterações' : 'Adicionar transação',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
