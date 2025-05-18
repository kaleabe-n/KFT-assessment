import 'package:go_router/go_router.dart';
import 'package:kft_consumer_mobile/lib.dart';

class AppRoutes {
  static const String splash = "splash";
  static const String login = "login";
  static const String signup = 'signup';
  static const String otp = 'otp';
  static const String forgotPassword = 'forgotPassword';
  static const String home = "home";
  static const String privacyPolicy = "privacyPolicy";
  static const String termsAndConditions = "termsAndConditions";
  static const String groupDetails = "groupDetails";
  static const String createGroupPage = "createGroupPage";
  static const String welcomeScreen = "welcomeScreen";
  static const String transactionDetail = "transactionDetail";
  static const String editProfile = "editProfile";
  static const String changePassword = "changePassword";
}

final routes = <GoRoute>[
  GoRoute(
    name: AppRoutes.login,
    path: "/login",
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    name: AppRoutes.signup,
    path: "/signup",
    builder: (context, state) => const SignUpPage(),
  ),
  GoRoute(
    name: AppRoutes.otp,
    path: "/otp/:email",
    builder: (context, state) => OTPPage(
      email: state.pathParameters['email']!,
    ),
  ),
  GoRoute(
    name: AppRoutes.home,
    path: "/home",
    builder: (context, state) => const BottomNav(),
  ),
  GoRoute(
    name: AppRoutes.splash,
    path: "/",
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    name: AppRoutes.transactionDetail,
    path: "/transaction-detail",
    builder: (context, state) {
      final transaction = state.extra as TransactionModel;
      return TransactionDetailPage(transaction: transaction);
    },
  ),
  GoRoute(
    name: AppRoutes.editProfile,
    path: "/edit-profile",
    builder: (context, state) {
      final currentUser = state.extra as UserModel;
      return EditProfilePage(currentUser: currentUser);
    },
  ),
  GoRoute(
    name: AppRoutes.changePassword,
    path: "/change-password",
    builder: (context, state) => const ChangePasswordPage(),
  ),
];
