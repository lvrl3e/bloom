import 'package:flutter/material.dart';

enum AccountType { bank, eWallet, cash, creditCard, other }

extension AccountTypeX on AccountType {
  String get label {
    switch (this) {
      case AccountType.bank:
        return 'Bank';
      case AccountType.eWallet:
        return 'E-Wallet';
      case AccountType.cash:
        return 'Cash';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.eWallet:
        return Icons.account_balance_wallet_rounded;
      case AccountType.cash:
        return Icons.payments_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
      case AccountType.other:
        return Icons.savings_rounded;
    }
  }

  static AccountType fromKey(String key) {
    return AccountType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => AccountType.other,
    );
  }
}

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currency = 'PHP',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountTypeX.fromKey(map['type'] as String),
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'PHP',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
