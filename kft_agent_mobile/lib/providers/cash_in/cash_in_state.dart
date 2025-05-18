part of 'cash_in_bloc.dart';

abstract class CashInState extends Equatable {
  const CashInState();

  @override
  List<Object> get props => [];
}

class CashInInitial extends CashInState {}

class CashInLoading extends CashInState {}

class CashInSuccess extends CashInState {
  final String message;
  final double agentNewBalance;

  const CashInSuccess({required this.message, required this.agentNewBalance});

  @override
  List<Object> get props => [message, agentNewBalance];
}

class CashInFailure extends CashInState {
  final String error;

  const CashInFailure({required this.error});

  @override
  List<Object> get props => [error];
}
