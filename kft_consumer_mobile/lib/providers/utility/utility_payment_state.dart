part of 'utility_payment_bloc.dart';

abstract class UtilityPaymentState extends Equatable {
  const UtilityPaymentState();

  @override
  List<Object> get props => [];
}

class UtilityPaymentInitial extends UtilityPaymentState {}

class UtilityPaymentLoading extends UtilityPaymentState {}

class UtilityPaymentSuccess extends UtilityPaymentState {
  final String message;
  final double newBalance;

  const UtilityPaymentSuccess(
      {required this.message, required this.newBalance});

  @override
  List<Object> get props => [message, newBalance];
}

class UtilityPaymentFailure extends UtilityPaymentState {
  final String error;

  const UtilityPaymentFailure({required this.error});

  @override
  List<Object> get props => [error];
}
