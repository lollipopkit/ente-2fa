import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:computer/computer.dart';
import 'package:ente_auth/app/app.dart';
import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/ente_theme_data.dart';
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/services/authenticator_service.dart';
import 'package:ente_auth/services/preference_service.dart';
import 'package:ente_auth/store/code_store.dart';
import 'package:ente_auth/ui/tools/app_lock.dart';
import 'package:ente_auth/ui/tools/lock_screen.dart';
import 'package:ente_auth/ui/utils/icon_utils.dart';
import 'package:ente_auth/utils/crypto_util.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_displaymode/flutter_displaymode.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  await _runInForeground(savedThemeMode);
  FlutterDisplayMode.setHighRefreshRate();
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
  Computer.shared().turnOn(workersCount: 4, verbose: kDebugMode);
  CryptoUtil.init();
  await PreferenceService.instance.init();
  await CodeStore.instance.init();
  await Configuration.instance.init();
  await AuthenticatorService.instance.init();
  await IconUtils.instance.init();
}
