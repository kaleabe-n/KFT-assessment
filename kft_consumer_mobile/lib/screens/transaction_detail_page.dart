import 'package:flutter/material.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        transaction.createdAt.toLocal().toString().split(" ")[0];
    final isDebit =
        transaction.transactionType.toLowerCase().contains('payment') ||
            transaction.transactionType.toLowerCase().contains('purchase');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.sp)),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDetailRow(
                  label: 'Transaction ID:',
                  value: transaction.id.toString(),
                ),
                _buildDetailRow(
                  label: 'Type:',
                  value: transaction.transactionType,
                  valueColor: isDebit ? Colors.redAccent : AppColors.primary,
                ),
                _buildDetailRow(
                  label: 'Amount:',
                  value:
                      '${isDebit ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                  valueColor: isDebit ? Colors.redAccent : AppColors.primary,
                  isBoldValue: true,
                ),
                _buildDetailRow(
                  label: 'Date & Time:',
                  value: formattedDate,
                ),
                SizedBox(height: 2.h),
                Center(
                  child: CustomButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Close',
                    width: 50.w,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required String label,
      required String value,
      Color? valueColor,
      bool isBoldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label,
              style: TextStyle(fontSize: 15.sp, color: Colors.grey[700])),
          Text(value,
              style: TextStyle(
                  fontSize: 15.sp,
                  color: valueColor ?? Colors.black87,
                  fontWeight:
                      isBoldValue ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
