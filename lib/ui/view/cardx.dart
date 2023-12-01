import 'package:ente_auth/theme.dart';
import 'package:flutter/material.dart';

class CardX extends StatelessWidget {
  const CardX(this.child, {super.key, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Theme.of(context).colorScheme.codeCardBackgroundColor,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
