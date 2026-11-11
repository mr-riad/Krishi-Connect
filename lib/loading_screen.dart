import 'dart:async';
import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'features/buyer/buyer_nav.dart';
import 'features/farmer/farmer_nav.dart';
import 'features/login_screen.dart';
import 'helpers/di.dart';
import 'helpers/helper_methods.dart';
import 'helpers/post_login.dart';
import 'networks/dio/dio.dart';
import 'welcome_screen.dart';

final class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadInitialData();

    _timer = Timer(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    try {
      await setInitValue();

      final bool isLoggedIn = appData.read(kKeyIsLoggedIn) == true;
      if (isLoggedIn) {
        final token = appData.read(kKeyAccessToken)?.toString() ?? '';
        if (token.isNotEmpty) {
          DioSingleton.instance.update(token);
        }
        await performPostLoginActions();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _timer?.cancel();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const WelcomeScreen();
    }

    final bool isLoggedIn = appData.read(kKeyIsLoggedIn) == true;
    if (isLoggedIn) {
      final role = appData.read(selectedRole)?.toString();
      if (role == 'buyer') {
        return const BuyerNav();
      }
      return const FarmerNav();
    }

    return const LoginScreen();
  }
}
