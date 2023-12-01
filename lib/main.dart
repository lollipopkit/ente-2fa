import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:computer/computer.dart';
import 'package:ente_auth/app.dart';
import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/core/utils/crypto_util.dart';
import 'package:ente_auth/data/services/auth.dart';
import 'package:ente_auth/data/services/preference.dart';
import 'package:ente_auth/data/store/code.dart';
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/theme.dart';
import 'package:ente_auth/ui/view/app_lock.dart';
import 'package:ente_auth/ui/view/issuer_icon.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  await _runInForeground(savedThemeMode);
}

Future<void> _runInForeground(AdaptiveThemeMode? savedThemeMode) async {
  await _init();
  final locale = await getLocale();
  runApp(
    AppLock(
      builder: (args) => App(locale: locale),
      lockScreen: const LockScreen(),
      enabled: Configuration.instance.shouldShowLockScreen(),
      locale: locale,
      lightTheme: lightThemeData,
      darkTheme: darkThemeData,
      savedThemeMode: _themeMode(savedThemeMode),
    ),
  );
}

ThemeMode _themeMode(AdaptiveThemeMode? savedThemeMode) {
  if (savedThemeMode == null) return ThemeMode.system;
  if (savedThemeMode.isLight) return ThemeMode.light;
  if (savedThemeMode.isDark) return ThemeMode.dark;
  return ThemeMode.system;
}

Future<void> _init() async {
  // Start workers asynchronously. No need to wait for them to start
  Computer.shared().turnOn(workersCount: 3, verbose: kDebugMode);
  CryptoUtil.init();
  await PreferenceService.instance.init();
  await CodeStore.instance.init();
  await Configuration.instance.init();
  await AuthenticatorService.instance.init();
  await IssuerIcon.instance.init();
}
