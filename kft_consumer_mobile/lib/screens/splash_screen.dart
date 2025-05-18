import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    final token = await dpLocator<AuthLocalDataSource>().getToken();

    if (mounted) {
      if (token != null) {
        context.goNamed(AppRoutes.home);
      } else {
        context.goNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        color: Colors.white,
      ),
    );
  }
}
