part of 'transactions_bloc.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  const LoadTransactions();
}
