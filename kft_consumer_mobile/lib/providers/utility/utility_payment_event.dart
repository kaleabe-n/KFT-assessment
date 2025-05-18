part of 'utility_payment_bloc.dart';

abstract class UtilityPaymentEvent extends Equatable {
  const UtilityPaymentEvent();

  @override
  List<Object?> get props => [];
}

class PayUtilitySubmitted extends UtilityPaymentEvent {
  final String utilityType;
  final double amount;
  final String? meterNumber;
  final String? phoneNumber;
  final String? agentEmail;

  const PayUtilitySubmitted(
      {required this.utilityType,
      required this.amount,
      this.meterNumber,
      this.phoneNumber,
      this.agentEmail});

  @override
  List<Object?> get props =>
      [utilityType, amount, meterNumber, phoneNumber, agentEmail];
}
