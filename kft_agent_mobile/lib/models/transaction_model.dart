import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final int id;
  final String agentUsername;
  final double amount;
  final String transactionType;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.agentUsername,
    required this.amount,
    required this.transactionType,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      agentUsername: json['agent_username'] as String,
      amount: double.parse(json['amount'] as String),
      transactionType: json['transaction_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, agentUsername, amount, transactionType, createdAt];
}
