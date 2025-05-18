import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final AgentDataProvider agentDataProvider;
  final AuthLocalDataSource authLocalDataSource;

  TransactionsBloc({
    required this.agentDataProvider,
    required this.authLocalDataSource,
  }) : super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(TransactionsLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final transactions =
          await agentDataProvider.getTransactionHistory(authToken: authToken);
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionsError(
          error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
