import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_consumer_mobile/lib.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final ConsumerDataProvider consumerDataProvider;
  final AuthLocalDataSource authLocalDataSource;

  PurchaseBloc({
    required this.consumerDataProvider,
    required this.authLocalDataSource,
  }) : super(PurchaseInitial()) {
    on<PurchaseSubmitted>(_onPurchaseSubmitted);
  }

  Future<void> _onPurchaseSubmitted(
    PurchaseSubmitted event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final result = await consumerDataProvider.buyProduct(
        productId: event.productId,
        authToken: authToken,
      );
      emit(PurchaseSuccess(
          message: result['message'],
          newBalance: result['consumer_new_balance']));
    } catch (e) {
      emit(
          PurchaseFailure(error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
