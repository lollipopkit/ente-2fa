import 'package:ente_auth/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future showToast(
  BuildContext context,
  String message, {
  toastLength = Toast.LENGTH_LONG,
  iOSDismissOnTap = true,
}) async {
  await Fluttertoast.cancel();
  return Fluttertoast.showToast(
    msg: message,
    toastLength: toastLength,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Theme.of(context).colorScheme.toastBackgroundColor,
    textColor: Theme.of(context).colorScheme.toastTextColor,
  );
}

Future<void> showShortToast(context, String message) {
  return showToast(context, message, toastLength: Toast.LENGTH_SHORT);
}
