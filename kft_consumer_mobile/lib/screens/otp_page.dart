import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OTPPage extends StatelessWidget {
  final String email;

  const OTPPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<OtpBloc>(),
      child: OTPView(email: email),
    );
  }
}

class OTPView extends StatefulWidget {
  final String email;

  const OTPView({super.key, required this.email});

  @override
  State<OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends State<OTPView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: BlocListener<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Account verified successfully!')),
              );
            context.goNamed(AppRoutes.home);
          } else if (state is OtpFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Verification Failed: ${state.error}')),
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
                  "Enter OTP",
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  "An OTP has been sent to ${widget.email}",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                CustomInputField(
                  controller: _otpController,
                  hintText: 'Enter OTP',
                  leadingIcon: Icons.vpn_key_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                BlocBuilder<OtpBloc, OtpState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: state is OtpLoading ? () {} : _submitOtp,
                      child: state is OtpLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Verify',
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

  void _submitOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<OtpBloc>().add(
            OtpSubmitted(
              email: widget.email,
              otpCode: _otpController.text,
            ),
          );
    }
  }
}
