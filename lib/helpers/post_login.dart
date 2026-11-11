// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../networks/dio/dio.dart';
import 'di.dart';

Future<void> performPostLoginActions() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final token = await user.getIdToken();
      if (token != null) {
        appData.write(kKeyAccessToken, token);
        DioSingleton.instance.update(token);
      }
    } catch (_) {}
  } else {
    final token = appData.read(kKeyAccessToken);
    if (token != null) {
      DioSingleton.instance.update(token);
    }
  }
}
