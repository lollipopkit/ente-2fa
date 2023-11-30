import 'package:flutter/material.dart';

Future<T?> routeToPage<T extends Object>(
  BuildContext context,
  Widget page, {
  bool forceCustomPageRoute = false,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return page;
      },
    ),
  );
}
