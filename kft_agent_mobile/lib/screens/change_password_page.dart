import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_agent_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<ChangePasswordBloc>(),
      child: const ChangePasswordView(),
    );
  }
}

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPassword1Controller = TextEditingController();
  final _newPassword2Controller = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPassword1Controller.dispose();
    _newPassword2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocListener<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Password changed successfully!')),
              );
            context.goNamed(AppRoutes.login);
          } else if (state is ChangePasswordFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text('Password Change Failed: ${state.error}')),
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
                CustomInputField(
                  controller: _oldPasswordController,
                  labelText: 'Old Password',
                  hintText: 'Enter your current password',
                  leadingIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _newPassword1Controller,
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  leadingIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _newPassword2Controller,
                  labelText: 'Confirm New Password',
                  hintText: 'Confirm your new password',
                  leadingIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPassword1Controller.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: state is ChangePasswordLoading
                          ? () {}
                          : _submitChangePassword,
                      child: state is ChangePasswordLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Change Password',
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

  void _submitChangePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ChangePasswordBloc>().add(
            ChangePasswordSubmitted(
              oldPassword: _oldPasswordController.text,
              newPassword1: _newPassword1Controller.text,
              newPassword2: _newPassword2Controller.text,
            ),
          );
    }
  }
}
