import 'package:flutter/material.dart';

Widget loadingIndicatorCircle({required BuildContext context, Color? color}) {
  return PopScope(
    canPop: false,
    child: Center(
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).primaryColor,
      ),
    ),
  );
}
