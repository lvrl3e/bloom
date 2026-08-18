enum TransactionType { income, expense, transfer }

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  static TransactionType fromKey(String key) {
    return TransactionType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => TransactionType.expense,
    );
  }
}

class MoneyTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String accountId;
  final String? toAccountId; // used only for transfers
  final DateTime date;
  final String? description;
  final String? notes;
  final DateTime createdAt;

  const MoneyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.accountId,
    this.toAccountId,
    required this.date,
    this.description,
    this.notes,
    required this.createdAt,
  });

  MoneyTransaction copyWith({
    TransactionType? type,
    double? amount,
    String? category,
    String? accountId,
    String? toAccountId,
    DateTime? date,
    String? description,
    String? notes,
  }) {
    return MoneyTransaction(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'category': category,
      'account_id': accountId,
      'to_account_id': toAccountId,
      'date': date.toIso8601String(),
      'description': description,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) {
    return MoneyTransaction(
      id: map['id'] as String,
      type: TransactionTypeX.fromKey(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      accountId: map['account_id'] as String,
      toAccountId: map['to_account_id'] as String?,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
