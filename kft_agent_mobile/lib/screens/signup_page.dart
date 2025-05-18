import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_agent_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<SignUpBloc>(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                    content: Text('OTP sent! Please check your email.')),
              );
            context
                .goNamed(AppRoutes.otp, pathParameters: {'email': state.email});
          } else if (state is SignUpFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Sign Up Failed: ${state.error}')),
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
                  "Create Account",
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                CustomInputField(
                  controller: _firstNameController,
                  hintText: 'First Name',
                  leadingIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _lastNameController,
                  hintText: 'Last Name',
                  leadingIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  leadingIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  leadingIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomInputField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  leadingIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                BlocBuilder<SignUpBloc, SignUpState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Sign Up',
                      onPressed: state is SignUpLoading
                          ? () {}
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<SignUpBloc>().add(
                                      SignUpSubmitted(
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      ),
                                    );
                              }
                            },
                      child: state is SignUpLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Sign Up',
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.white)),
                    );
                  },
                ),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () => context.goNamed(AppRoutes.login),
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
