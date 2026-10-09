// ignore_for_file: unused_element

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../features/login_screen.dart';

// Screens to be implemented as features are created
// import 'package:sandraluty/features/...';

final class Routes {
  static final Routes _routes = Routes._internal();
  Routes._internal();
  static Routes get instance => _routes;

  // Auth Routes
  static const String loginScreen = '/logIn';
  static const String signUpScreen = '/signUp';
  static const String clientSignUp = '/clientSignUp';
  static const String providerSignUp = '/providerSignUp';
  static const String forgotPWScreen = '/ForgotPWScreen';
  static const String otpScreen = '/OtpScreen';
  static const String personalInformationScreen = '/personalInformationScreen';
  static const String providerNavigationScreen = '/providerNavigationScreen';
  static const String jobDetailsScreen = '/jobDetailsScreen';
  static const String bitSubmitScreen = '/bitSubmitScreen';
  static const String confromBitScreen = '/confromBitScreen';
  static const String chatScreen = '/chatScreen';
  static const String editProfileScreen = '/editProfileScreen';
  static const String notificationSettingScreen = '/notificationSettingScreen';
  static const String notificatioScreen = '/notificatioScreen';
  static const String setPasswordScreen = '/setPasswordScreen';
  //products_with_pagination
  static const String productsWithPagination = '/ProductsWithPagination';
  //ProductsScreen
  static const String productsScreen = '/ProductsScreen';
  //ProductDetailsScreen
  static const String productDetailsScreen = '/ProductDetailsScreen';

  // Main App Routes
  static const String homeScreen = '/home_screen';

  static const String checkoutScreen = '/checkoutScreen';
  static const String reviewPlanScreen = '/reviewPlanScreen';
  static const String paymentConfirmScren = '/paymentConfirmScren';
  static const String profileScreen = '/profileScreen';
  static const String paymentSetting = '/paymentSetting';
  static const String reviewScreen = '/reviewScreen';
  static const String clientNavigationScreen = '/clientNavigationScreen';
  static const String clientJobPostScreen = '/clientJobPostScreen';
  static const String clientBitScreen = '/clientBitScreen';
  static const String clientMessageProfileScreen =
      '/clientMessageProfileScreen';
  static const String clientQuotesScreen = '/clientQuotesScreen';
  static const String constractorProfileScreen = '/constractorProfileScreen';
}

final class RouteGenerator {
  static final RouteGenerator _routeGenerator = RouteGenerator._internal();
  RouteGenerator._internal();
  static RouteGenerator get instance => _routeGenerator;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case Routes.loginScreen:
        return defaultTargetPlatform == TargetPlatform.iOS
            ? CupertinoPageRoute(builder: (context) => const LoginScreen())
            : _FadedTransitionRoute(
                widget: const LoginScreen(),
                settings: settings,
              );

      // Other routes can be enabled once screens are built
      default:
        return null;
    }
  }
}

class _FadedTransitionRoute extends PageRouteBuilder {
  final Widget widget;
  @override
  final RouteSettings settings;

  _FadedTransitionRoute({required this.widget, required this.settings})
    : super(
        settings: settings,
        reverseTransitionDuration: const Duration(milliseconds: 1),
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return widget;
            },
        transitionDuration: const Duration(milliseconds: 1),
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.ease),
                child: child,
              );
            },
      );
}

class ScreenTitle extends StatelessWidget {
  final Widget widget;

  const ScreenTitle({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: .5, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: widget,
    );
  }
}
