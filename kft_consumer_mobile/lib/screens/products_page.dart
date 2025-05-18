import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<ProductsBloc>()..add(const LoadProducts()),
      child: BlocProvider(
        create: (context) => dpLocator<PurchaseBloc>(),
        child: const ProductsView(),
      ),
    );
  }
}

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PurchaseBloc, PurchaseState>(
        listener: (context, purchaseState) {
          if (purchaseState is PurchaseSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(
                        '${purchaseState.message} New balance: ${purchaseState.newBalance}')),
              );
          } else if (purchaseState is PurchaseFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text('Purchase Failed: ${purchaseState.error}')),
              );
          }
        },
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductsError) {
              return Center(child: Text('Error: ${state.error}'));
            } else if (state is ProductsLoaded) {
              if (state.products.isEmpty) {
                return const Center(child: Text('No products available.'));
              }
              return ListView.builder(
                padding: EdgeInsets.all(16.sp),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 0),
                    elevation: 4,
                    child: ListTile(
                      title: Text(product.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 0.5.h),
                          Text(product.description,
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.grey[700])),
                          SizedBox(height: 0.5.h),
                          Text('\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined,
                            color: AppColors.primary),
                        onPressed: () => _confirmPurchase(context, product),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Select a tab'));
          },
        ),
      ),
    );
  }

  void _confirmPurchase(BuildContext context, ProductModel product) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirm Purchase'),
            content: Text(
                'Are you sure you want to buy "${product.name}" for \$${product.price.toStringAsFixed(2)}?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context
                      .read<PurchaseBloc>()
                      .add(PurchaseSubmitted(productId: product.id));
                },
              ),
            ],
          );
        });
  }
}
