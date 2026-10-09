// ignore_for_file: use_build_context_synchronously

import '../constants/app_constants.dart';
import '../networks/dio/dio.dart';
import 'di.dart';

Future<void> performPostLoginActions() async {
  final token = appData.read(kKeyAccessToken);
  DioSingleton.instance.update(token);
}
