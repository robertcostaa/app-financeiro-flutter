enum Category { alimentacao, transporte, lazer, salario, outros }

extension CategoryLabel on Category {
  String get label {
    switch (this) {
      case Category.alimentacao:
        return 'Alimentação';
      case Category.transporte:
        return 'Transporte';
      case Category.lazer:
        return 'Lazer';
      case Category.salario:
        return 'Salário';
      case Category.outros:
        return 'Outros';
    }
  }
}

class TransactionModel {
  final int? id;
  final String? firebaseId;
  final int userId;
  final String title;
  final double value;
  final bool isIncome;
  final Category category;
  final DateTime date;

  TransactionModel({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.title,
    required this.value,
    required this.isIncome,
    required this.category,
    required this.date,
  });

  TransactionModel copyWith({
    int? id,
    String? firebaseId,
    int? userId,
    String? title,
    double? value,
    bool? isIncome,
    Category? category,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      value: value ?? this.value,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'userId': userId,
      'title': title,
      'value': value,
      'isIncome': isIncome ? 1 : 0,
      'category': category.name,
      'date': date.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'firebaseId': firebaseId,
      'userId': userId,
      'title': title,
      'value': value,
      'isIncome': isIncome,
      'category': category.name,
      'date': date.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      firebaseId: map['firebaseId'] as String?,
      userId: map['userId'] as int,
      title: map['title'] as String,
      value: (map['value'] as num).toDouble(),
      isIncome: map['isIncome'] == 1,
      category: Category.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => Category.outros,
      ),
      date: DateTime.parse(map['date'] as String),
    );
  }

  factory TransactionModel.fromFirebaseMap(
    Map<String, dynamic> map,
    String firebaseId,
  ) {
    return TransactionModel(
      firebaseId: firebaseId,
      userId: map['userId'] as int,
      title: map['title'] as String,
      value: (map['value'] as num).toDouble(),
      isIncome: map['isIncome'] as bool,
      category: Category.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => Category.outros,
      ),
      date: DateTime.parse(map['date'] as String),
    );
  }
}
