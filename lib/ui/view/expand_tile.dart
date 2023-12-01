import 'package:flutter/material.dart';

const _shape = Border();

class ExpandTile extends ExpansionTile {
  const ExpandTile({
    super.key,
    super.leading,
    required super.title,
    super.children,
    super.subtitle,
    super.initiallyExpanded,
    super.tilePadding,
    super.childrenPadding = const EdgeInsets.only(left: 37),
    super.trailing,
    super.controller,
  }) : super(shape: _shape, collapsedShape: _shape);
}