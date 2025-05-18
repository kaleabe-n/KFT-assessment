import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'utility_payment_event.dart';
part 'utility_payment_state.dart';

class UtilityPaymentBloc
    extends Bloc<UtilityPaymentEvent, UtilityPaymentState> {
  final AgentDataProvider agentDataProvider;
  final AuthLocalDataSource authLocalDataSource;

  UtilityPaymentBloc({
    required this.agentDataProvider,
    required this.authLocalDataSource,
  }) : super(UtilityPaymentInitial()) {
    on<PayUtilitySubmitted>(_onPayUtilitySubmitted);
  }

  Future<void> _onPayUtilitySubmitted(
    PayUtilitySubmitted event,
    Emitter<UtilityPaymentState> emit,
  ) async {
    emit(UtilityPaymentLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final result = await agentDataProvider.payUtilityAsAgent(
        utilityType: event.utilityType,
        amount: event.amount,
        meterNumber: event.meterNumber,
        phoneNumber: event.phoneNumber,
        authToken: authToken,
      );
      emit(UtilityPaymentSuccess(
          message: result['message'], newBalance: result['agent_new_balance']));
    } catch (e) {
      emit(UtilityPaymentFailure(
          error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
