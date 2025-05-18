part of 'transactions_bloc.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;

  const TransactionsLoaded({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class TransactionsError extends TransactionsState {
  final String error;

  const TransactionsError({required this.error});

  @override
  List<Object> get props => [error];
}
