import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kft_agent_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<UtilityPaymentBloc>(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _utilityDetailController = TextEditingController();

  String _selectedUtilityType = 'electricity';
  final List<String> _utilityTypes = ['electricity', 'water', 'mobile_topup'];

  @override
  void dispose() {
    _amountController.dispose();
    _utilityDetailController.dispose();
    super.dispose();
  }

  String _getUtilityDetailLabel() {
    switch (_selectedUtilityType) {
      case 'electricity':
      case 'water':
        return 'Meter Number';
      case 'mobile_topup':
        return 'Phone Number';
      default:
        return 'Detail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UtilityPaymentBloc, UtilityPaymentState>(
        listener: (context, state) {
          if (state is UtilityPaymentSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(
                        '${state.message} New balance: ${state.newBalance}')),
              );
            _amountController.clear();
            _utilityDetailController.clear();
          } else if (state is UtilityPaymentFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Payment Failed: ${state.error}')),
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
                  "Pay Utility",
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                DropdownButtonFormField<String>(
                  value: _selectedUtilityType,
                  items: _utilityTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type.replaceFirst('_', ' ').titleCase),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedUtilityType = newValue;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Utility Type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _utilityDetailController,
                  hintText: _getUtilityDetailLabel(),
                  labelText: _getUtilityDetailLabel(),
                  leadingIcon: Icons.numbers,
                  keyboardType: _selectedUtilityType == 'mobile_topup'
                      ? TextInputType.phone
                      : TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${_getUtilityDetailLabel()} is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _amountController,
                  hintText: 'Amount',
                  labelText: 'Amount',
                  leadingIcon: Icons.attach_money,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid positive amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                BlocBuilder<UtilityPaymentBloc, UtilityPaymentState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: state is UtilityPaymentLoading
                          ? () {}
                          : _submitPayment,
                      child: state is UtilityPaymentLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Pay',
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

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final utilityDetail = _utilityDetailController.text;

      context.read<UtilityPaymentBloc>().add(
            PayUtilitySubmitted(
              utilityType: _selectedUtilityType,
              amount: amount,
              meterNumber:
                  _selectedUtilityType != 'mobile_topup' ? utilityDetail : null,
              phoneNumber:
                  _selectedUtilityType == 'mobile_topup' ? utilityDetail : null,
            ),
          );
    }
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get titleCase => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
