part of 'purchase_bloc.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object> get props => [];
}

class PurchaseSubmitted extends PurchaseEvent {
  final int productId;

  const PurchaseSubmitted({required this.productId});

  @override
  List<Object> get props => [productId];
}
