import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kft_agent_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CashInPage extends StatelessWidget {
  const CashInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<CashInBloc>(),
      child: const CashInView(),
    );
  }
}

class CashInView extends StatefulWidget {
  const CashInView({super.key});

  @override
  State<CashInView> createState() => _CashInViewState();
}

class _CashInViewState extends State<CashInView> {
  final _formKey = GlobalKey<FormState>();
  final _consumerEmailController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _consumerEmailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CashInBloc, CashInState>(
        listener: (context, state) {
          if (state is CashInSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(
                        '${state.message} Your new balance: ${state.agentNewBalance.toStringAsFixed(2)}')),
              );
            _consumerEmailController.clear();
            _amountController.clear();
          } else if (state is CashInFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Cash-in Failed: ${state.error}')),
              );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 2.h),
                Text(
                  "Cash-in to Consumer",
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                CustomInputField(
                  controller: _consumerEmailController,
                  labelText: 'Consumer Email',
                  hintText: 'Enter consumer\'s email address',
                  leadingIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter consumer email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _amountController,
                  labelText: 'Amount',
                  hintText: 'Enter amount to cash-in',
                  leadingIcon: Icons.attach_money,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid positive amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                BlocBuilder<CashInBloc, CashInState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: state is CashInLoading ? () {} : _submitCashIn,
                      child: state is CashInLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Submit Cash-in',
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.white)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitCashIn() {
    if (_formKey.currentState!.validate()) {
      final consumerEmail = _consumerEmailController.text;
      final amount = double.parse(_amountController.text);
      context
          .read<CashInBloc>()
          .add(CashInSubmitted(consumerEmail: consumerEmail, amount: amount));
    }
  }
}
