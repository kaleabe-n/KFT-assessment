import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kft_agent_mobile/lib.dart';

class AppRouter extends StatelessWidget {
  static final GoRouter router = createRoute();

  static GoRouter createRoute() {
    return GoRouter(
      initialLocation: "/",
      routes: routes,
    );
  }

  AppRouter({
    super.key,
  }) {
    (context, state) => const MaterialPage(
          key: ValueKey('errorPage'),
          child: Scaffold(
            body: Center(
              child: Text(
                "page not found",
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) => child ?? const SizedBox.shrink(),
      debugShowCheckedModeBanner: false,
      title: 'KFT agent',
      theme: ThemeData(fontFamily: 'Roboto'),
      routerConfig: router,
    );
  }
}
