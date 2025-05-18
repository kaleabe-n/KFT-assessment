import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          dpLocator<TransactionsBloc>()..add(const LoadTransactions()),
      child: const TransactionsView(),
    );
  }
}

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionsError) {
            return Center(child: Text('Error: ${state.error}'));
          } else if (state is TransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(child: Text('No transactions yet.'));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.sp),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                final formattedDate =
                    transaction.createdAt.toLocal().toString().split(' ')[0];
                final isDebit = transaction.transactionType
                        .toLowerCase()
                        .contains('payment') ||
                    transaction.transactionType
                        .toLowerCase()
                        .contains('purchase') ||
                    transaction.transactionType
                        .toLowerCase()
                        .contains('cash-out');

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 0.8.h),
                  elevation: 2,
                  child: ListTile(
                    onTap: () {
                      context.pushNamed(AppRoutes.transactionDetail,
                          extra: transaction);
                    },
                    leading: Icon(
                      isDebit
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isDebit ? Colors.redAccent : AppColors.primary,
                      size: 20.sp,
                    ),
                    title: Text(
                      transaction.transactionType,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15.sp),
                    ),
                    subtitle: Text(
                      formattedDate,
                      style:
                          TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      '${isDebit ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: isDebit ? Colors.redAccent : AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Loading transactions...'));
        },
      ),
    );
  }
}
