import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        price: double.parse(json['price'] as String));
  }

  @override
  List<Object?> get props => [id, name, description, price];
}
