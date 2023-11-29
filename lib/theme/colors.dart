import 'dart:ui';

import 'package:flutter/material.dart';

class EnteColorScheme {
  // Background Colors
  final Color backgroundBase;
  final Color backgroundElevated;
  final Color backgroundElevated2;

  // Backdrop Colors
  final Color backdropBase;
  final Color backdropBaseMute;
  final Color backdropFaint;

  // Text Colors
  final Color textBase;
  final Color textMuted;
  final Color textFaint;

  // Fill Colors
  final Color fillBase;
  final Color fillBasePressed;
  final Color fillMuted;
  final Color fillFaint;
  final Color fillFaintPressed;

  // Stroke Colors
  final Color strokeBase;
  final Color strokeMuted;
  final Color strokeFaint;
  final Color strokeFainter;
  final Color blurStrokeBase;
  final Color blurStrokeFaint;
  final Color blurStrokePressed;

  // Fixed Colors
  final Color primaryGreen;
  final Color primary700;
  final Color primary500;
  final Color primary400;
  final Color primary300;

  final Color warning700;
  final Color warning500;
  final Color warning400;
  final Color warning800;

  final Color caution500;
  final List<Color> avatarColors;
  const EnteColorScheme(
    this.backgroundBase,
    this.backgroundElevated,
    this.backgroundElevated2,
    this.backdropBase,
    this.backdropBaseMute,
    this.backdropFaint,
    this.textBase,
    this.textMuted,
    this.textFaint,
    this.fillBase,
    this.fillBasePressed,
    this.fillMuted,
    this.fillFaint,
    this.fillFaintPressed,
    this.strokeBase,
    this.strokeMuted,
    this.strokeFaint,
    this.strokeFainter,
    this.blurStrokeBase,
    this.blurStrokeFaint,
    this.blurStrokePressed,
    this.avatarColors, {
    this.primaryGreen = _primaryGreen,
    this.primary700 = _primary700,
    this.primary500 = _primary500,
    this.primary400 = _primary400,
    this.primary300 = _primary300,
    this.warning700 = _warning700,
    this.warning800 = _warning800,
    this.warning500 = _warning500,
    this.warning400 = _warning700,
    this.caution500 = _caution500,
  });
}

const EnteColorScheme lightScheme = EnteColorScheme(
  backgroundBaseLight,
  backgroundElevatedLight,
  backgroundElevated2Light,
  backdropBaseLight,
  backdropMutedLight,
  backdropFaintLight,
  textBaseLight,
  textMutedLight,
  textFaintLight,
  fillBaseLight,
  fillBasePressedLight,
  fillMutedLight,
  fillFaintLight,
  fillFaintPressedLight,
  strokeBaseLight,
  strokeMutedLight,
  strokeFaintLight,
  strokeFainterLight,
  blurStrokeBaseLight,
  blurStrokeFaintLight,
  blurStrokePressedLight,
  avatarLight,
);

const EnteColorScheme darkScheme = EnteColorScheme(
  backgroundBaseDark,
  backgroundElevatedDark,
  backgroundElevated2Dark,
  backdropBaseDark,
  backdropMutedDark,
  backdropFaintDark,
  textBaseDark,
  textMutedDark,
  textFaintDark,
  fillBaseDark,
  fillBasePressedDark,
  fillMutedDark,
  fillFaintDark,
  fillFaintPressedDark,
  strokeBaseDark,
  strokeMutedDark,
  strokeFaintDark,
  strokeFainterDark,
  blurStrokeBaseDark,
  blurStrokeFaintDark,
  blurStrokePressedDark,
  avatarDark,
);

// Background Colors
const Color backgroundBaseLight = Color.fromRGBO(255, 255, 255, 1);
const Color backgroundElevatedLight = Color.fromRGBO(255, 255, 255, 1);
const Color backgroundElevated2Light = Color.fromRGBO(251, 251, 251, 1);

const Color backgroundBaseDark = Color.fromRGBO(0, 0, 0, 1);
const Color backgroundElevatedDark = Color.fromRGBO(27, 27, 27, 1);
const Color backgroundElevated2Dark = Color.fromRGBO(37, 37, 37, 1);

// Backdrop Colors
const Color backdropBaseLight = Color.fromRGBO(255, 255, 255, 0.92);
const Color backdropMutedLight = Color.fromRGBO(255, 255, 255, 0.75);
const Color backdropFaintLight = Color.fromRGBO(255, 255, 255, 0.30);

const Color backdropBaseDark = Color.fromRGBO(0, 0, 0, 0.90);
const Color backdropMutedDark = Color.fromRGBO(0, 0, 0, 0.65);
const Color backdropFaintDark = Color.fromRGBO(0, 0, 0, 0.20);

// Text Colors
const Color textBaseLight = Color.fromRGBO(0, 0, 0, 1);
const Color textMutedLight = Color.fromRGBO(0, 0, 0, 0.6);
const Color textFaintLight = Color.fromRGBO(0, 0, 0, 0.5);

const Color textBaseDark = Color.fromRGBO(255, 255, 255, 1);
const Color textMutedDark = Color.fromRGBO(255, 255, 255, 0.7);
const Color textFaintDark = Color.fromRGBO(255, 255, 255, 0.5);

// Fill Colors
const Color fillBaseLight = Color.fromRGBO(0, 0, 0, 1);
const Color fillBasePressedLight = Color.fromRGBO(0, 0, 0, 0.87);
const Color fillMutedLight = Color.fromRGBO(0, 0, 0, 0.12);
const Color fillFaintLight = Color.fromRGBO(0, 0, 0, 0.04);
const Color fillFaintPressedLight = Color.fromRGBO(0, 0, 0, 0.08);

const Color fillBaseDark = Color.fromRGBO(255, 255, 255, 1);
const Color fillBasePressedDark = Color.fromRGBO(255, 255, 255, 0.9);
const Color fillMutedDark = Color.fromRGBO(255, 255, 255, 0.16);
const Color fillFaintDark = Color.fromRGBO(255, 255, 255, 0.12);
const Color fillFaintPressedDark = Color.fromRGBO(255, 255, 255, 0.06);

// Stroke Colors
const Color strokeBaseLight = Color.fromRGBO(0, 0, 0, 1);
const Color strokeMutedLight = Color.fromRGBO(0, 0, 0, 0.24);
const Color strokeFaintLight = Color.fromRGBO(0, 0, 0, 0.04);
const Color strokeFainterLight = Color.fromRGBO(0, 0, 0, 0.06);
const Color blurStrokeBaseLight = Color.fromRGBO(0, 0, 0, 0.65);
const Color blurStrokeFaintLight = Color.fromRGBO(0, 0, 0, 0.08);
const Color blurStrokePressedLight = Color.fromRGBO(0, 0, 0, 0.50);

const Color strokeBaseDark = Color.fromRGBO(255, 255, 255, 1);
const Color strokeMutedDark = Color.fromRGBO(255, 255, 255, 0.24);
const Color strokeFaintDark = Color.fromRGBO(255, 255, 255, 0.16);
const Color strokeFainterDark = Color.fromRGBO(255, 255, 255, 0.08);
const Color blurStrokeBaseDark = Color.fromRGBO(255, 255, 255, 0.90);
const Color blurStrokeFaintDark = Color.fromRGBO(255, 255, 255, 0.06);
const Color blurStrokePressedDark = Color.fromRGBO(255, 255, 255, 0.50);

// Fixed Colors

const Color _primaryGreen = Color.fromRGBO(29, 185, 84, 1);

const Color _primary700 = Color.fromARGB(255, 164, 0, 182);
const Color _primary500 = Color.fromARGB(255, 204, 10, 101);
const Color _primary400 = Color.fromARGB(255, 122, 41, 193);
const Color _primary300 = Color.fromARGB(255, 152, 77, 244);

const Color _warning700 = Color.fromRGBO(234, 63, 63, 1);
const Color _warning500 = Color.fromRGBO(255, 101, 101, 1);
const Color _warning800 = Color(0xFFF53434);
const Color warning500 = Color.fromRGBO(255, 101, 101, 1);
// const Color _warning400 = Color.fromRGBO(255, 111, 111, 1);

const Color _caution500 = Color.fromRGBO(255, 194, 71, 1);

const List<Color> avatarLight = [
  Color.fromRGBO(118, 84, 154, 1),
  Color.fromRGBO(223, 120, 97, 1),
  Color.fromRGBO(148, 180, 159, 1),
  Color.fromRGBO(135, 162, 251, 1),
  Color.fromRGBO(198, 137, 198, 1),
  Color.fromRGBO(198, 137, 198, 1),
  Color.fromRGBO(50, 82, 136, 1),
  Color.fromRGBO(133, 180, 224, 1),
  Color.fromRGBO(193, 163, 163, 1),
  Color.fromRGBO(193, 163, 163, 1),
  Color.fromRGBO(66, 97, 101, 1),
  Color.fromRGBO(66, 97, 101, 1),
  Color.fromRGBO(66, 97, 101, 1),
  Color.fromRGBO(221, 157, 226, 1),
  Color.fromRGBO(130, 171, 139, 1),
  Color.fromRGBO(155, 187, 232, 1),
  Color.fromRGBO(143, 190, 190, 1),
  Color.fromRGBO(138, 195, 161, 1),
  Color.fromRGBO(168, 176, 242, 1),
  Color.fromRGBO(176, 198, 149, 1),
  Color.fromRGBO(233, 154, 173, 1),
  Color.fromRGBO(209, 132, 132, 1),
  Color.fromRGBO(120, 181, 167, 1),
];

const List<Color> avatarDark = [
  Color.fromRGBO(118, 84, 154, 1),
  Color.fromRGBO(223, 120, 97, 1),
  Color.fromRGBO(148, 180, 159, 1),
  Color.fromRGBO(135, 162, 251, 1),
  Color.fromRGBO(198, 137, 198, 1),
  Color.fromRGBO(147, 125, 194, 1),
  Color.fromRGBO(50, 82, 136, 1),
  Color.fromRGBO(133, 180, 224, 1),
  Color.fromRGBO(193, 163, 163, 1),
  Color.fromRGBO(225, 160, 89, 1),
  Color.fromRGBO(66, 97, 101, 1),
  Color.fromRGBO(107, 119, 178, 1),
  Color.fromRGBO(149, 127, 239, 1),
  Color.fromRGBO(221, 157, 226, 1),
  Color.fromRGBO(130, 171, 139, 1),
  Color.fromRGBO(155, 187, 232, 1),
  Color.fromRGBO(143, 190, 190, 1),
  Color.fromRGBO(138, 195, 161, 1),
  Color.fromRGBO(168, 176, 242, 1),
  Color.fromRGBO(176, 198, 149, 1),
  Color.fromRGBO(233, 154, 173, 1),
  Color.fromRGBO(209, 132, 132, 1),
  Color.fromRGBO(120, 181, 167, 1),
];
