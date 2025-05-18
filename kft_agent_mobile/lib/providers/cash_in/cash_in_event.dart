part of 'cash_in_bloc.dart';

abstract class CashInEvent extends Equatable {
  const CashInEvent();

  @override
  List<Object> get props => [];
}

class CashInSubmitted extends CashInEvent {
  final String consumerEmail;
  final double amount;

  const CashInSubmitted({required this.consumerEmail, required this.amount});

  @override
  List<Object> get props => [consumerEmail, amount];
}
