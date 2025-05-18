import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_consumer_mobile/lib.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ConsumerDataProvider consumerDataProvider;
  final AuthLocalDataSource authLocalDataSource;

  ProductsBloc({
    required this.consumerDataProvider,
    required this.authLocalDataSource,
  }) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final products =
          await consumerDataProvider.getProducts(authToken: authToken);
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
