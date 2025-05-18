part of 'purchase_bloc.dart';

abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object> get props => [];
}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseSuccess extends PurchaseState {
  final String message;
  final double newBalance;

  const PurchaseSuccess({required this.message, required this.newBalance});

  @override
  List<Object> get props => [message, newBalance];
}

class PurchaseFailure extends PurchaseState {
  final String error;

  const PurchaseFailure({required this.error});

  @override
  List<Object> get props => [error];
}
