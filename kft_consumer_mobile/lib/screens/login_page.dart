import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dpLocator<LoginBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Login Successful!')),
              );
            context.goNamed(AppRoutes.home);
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Login Failed: ${state.error}')),
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
                SizedBox(height: 5.h),
                Text(
                  "Welcome Back!",
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
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
                    return null;
                  },
                ),
                SizedBox(height: 4.h),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: state is LoginLoading ? () {} : _submitLogin,
                      child: state is LoginLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Login',
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.white)),
                    );
                  },
                ),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () => context.goNamed(AppRoutes.signup),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
            LoginSubmitted(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }
}
