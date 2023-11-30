import 'package:flutter/material.dart';

class HomeHeaderWidget extends StatefulWidget {
  final Widget centerWidget;
  const HomeHeaderWidget({required this.centerWidget, Key? key})
      : super(key: key);

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    final hasNotch = View.of(context).viewPadding.top > 65;
    return Padding(
      padding: EdgeInsets.fromLTRB(4, hasNotch ? 4 : 8, 4, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            splashColor: Colors.transparent,
            icon: const Icon(
              Icons.menu_outlined,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: widget.centerWidget,
          ),
        ],
      ),
    );
  }
}
