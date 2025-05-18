import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'cash_in_event.dart';
part 'cash_in_state.dart';

class CashInBloc extends Bloc<CashInEvent, CashInState> {
  final AgentDataProvider agentDataProvider;
  final AuthLocalDataSource authLocalDataSource =
      dpLocator<AuthLocalDataSource>();

  CashInBloc({
    required this.agentDataProvider,
  }) : super(CashInInitial()) {
    on<CashInSubmitted>(_onCashInSubmitted);
  }

  Future<void> _onCashInSubmitted(
    CashInSubmitted event,
    Emitter<CashInState> emit,
  ) async {
    emit(CashInLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Agent please log in.");
      }

      final result = await agentDataProvider.cashInToConsumer(
        consumerEmail: event.consumerEmail,
        amount: event.amount,
        authToken: authToken,
      );
      emit(CashInSuccess(
          message: result['message'],
          agentNewBalance: result['agent_new_balance']));
    } catch (e) {
      emit(CashInFailure(error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
