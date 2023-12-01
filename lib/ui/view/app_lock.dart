import 'dart:async';
import 'dart:io';

import 'package:ente_auth/core/utils/auth_util.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/ui/common/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// A widget which handles app lifecycle events for showing and hiding a lock screen.
/// This should wrap around a `MyApp` widget (or equivalent).
///
/// [lockScreen] is a [Widget] which should be a screen for handling login logic and
/// calling `AppLock.of(context).didUnlock();` upon a successful login.
///
/// [builder] is a [Function] taking an [Object] as its argument and should return a
/// [Widget]. The [Object] argument is provided by the [lockScreen] calling
/// `AppLock.of(context).didUnlock();` with an argument. [Object] can then be injected
/// in to your `MyApp` widget (or equivalent).
///
/// [enabled] determines wether or not the [lockScreen] should be shown on app launch
/// and subsequent app pauses. This can be changed later on using `AppLock.of(context).enable();`,
/// `AppLock.of(context).disable();` or the convenience method `AppLock.of(context).setEnabled(enabled);`
/// using a bool argument.
///
/// [backgroundLockLatency] determines how much time is allowed to pass when
/// the app is in the background state before the [lockScreen] widget should be
/// shown upon returning. It defaults to instantly.
///

// ignore_for_file: unnecessary_this, library_private_types_in_public_api
class AppLock extends StatefulWidget {
  final Widget Function(Object?) builder;
  final Widget lockScreen;
  final bool enabled;
  final Duration backgroundLockLatency;
  final ThemeData? darkTheme;
  final ThemeData? lightTheme;
  final ThemeMode savedThemeMode;
  final Locale? locale;

  const AppLock({
    super.key,
    required this.builder,
    required this.lockScreen,
    required this.savedThemeMode,
    this.enabled = true,
    this.locale,
    this.backgroundLockLatency = const Duration(seconds: 0),
    this.darkTheme,
    this.lightTheme,
  });

  static _AppLockState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppLockState>();

  @override
  State<AppLock> createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  late bool _didUnlockForAppLaunch;
  late bool _isLocked;
  late bool _enabled;

  Timer? _backgroundLockLatencyTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    this._didUnlockForAppLaunch = !this.widget.enabled;
    this._isLocked = false;
    this._enabled = this.widget.enabled;

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!this._enabled) {
      return;
    }

    if (state == AppLifecycleState.paused &&
        (!this._isLocked && this._didUnlockForAppLaunch)) {
      this._backgroundLockLatencyTimer =
          Timer(this.widget.backgroundLockLatency, () => this.showLockScreen());
    }

    if (state == AppLifecycleState.resumed) {
      this._backgroundLockLatencyTimer?.cancel();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    this._backgroundLockLatencyTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: this.widget.enabled ? this._lockScreen : this.widget.builder(null),
      navigatorKey: _navigatorKey,
      themeMode: widget.savedThemeMode,
      theme: widget.lightTheme,
      darkTheme: widget.darkTheme,
      locale: widget.locale,
      supportedLocales: appSupportedLocales,
      localeListResolutionCallback: localResolutionCallBack,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
      ],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/lock-screen':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => this._lockScreen,
            );
          case '/unlocked':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  this.widget.builder(settings.arguments),
            );
        }
        return PageRouteBuilder(pageBuilder: (_, __, ___) => this._lockScreen);
      },
    );
  }

  Widget get _lockScreen {
    return WillPopScope(
      child: this.widget.lockScreen,
      onWillPop: () => Future.value(false),
    );
  }

  /// Causes `AppLock` to either pop the [lockScreen] if the app is already running
  /// or instantiates widget returned from the [builder] method if the app is cold
  /// launched.
  ///
  /// [args] is an optional argument which will get passed to the [builder] method
  /// when built. Use this when you want to inject objects created from the
  /// [lockScreen] in to the rest of your app so you can better guarantee that some
  /// objects, services or databases are already instantiated before using them.
  void didUnlock([Object? args]) {
    if (this._didUnlockForAppLaunch) {
      this._didUnlockOnAppPaused();
    } else {
      this._didUnlockOnAppLaunch(args);
    }
  }

  /// Makes sure that [AppLock] shows the [lockScreen] on subsequent app pauses if
  /// [enabled] is true of makes sure it isn't shown on subsequent app pauses if
  /// [enabled] is false.
  ///
  /// This is a convenience method for calling the [enable] or [disable] method based
  /// on [enabled].
  void setEnabled(bool enabled) {
    if (enabled) {
      this.enable();
    } else {
      this.disable();
    }
  }

  /// Makes sure that [AppLock] shows the [lockScreen] on subsequent app pauses.
  void enable() {
    setState(() {
      this._enabled = true;
    });
  }

  /// Makes sure that [AppLock] doesn't show the [lockScreen] on subsequent app pauses.
  void disable() {
    setState(() {
      this._enabled = false;
    });
  }

  /// Manually show the [lockScreen].
  Future<void> showLockScreen() {
    this._isLocked = true;
    return _navigatorKey.currentState!.pushNamed('/lock-screen');
  }

  void _didUnlockOnAppLaunch(Object? args) {
    this._didUnlockForAppLaunch = true;
    _navigatorKey.currentState!
        .pushReplacementNamed('/unlocked', arguments: args);
  }

  void _didUnlockOnAppPaused() {
    this._isLocked = false;
    _navigatorKey.currentState!.pop();
  }
}


class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final _logger = Logger("LockScreen");
  bool _isShowingLockScreen = false;
  bool _hasPlacedAppInBackground = false;
  bool _hasAuthenticationFailed = false;
  int? lastAuthenticatingTime;

  @override
  void initState() {
    _logger.info("initiatingState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isNonMobileIOSDevice()) {
        _logger.info('ignore init for non mobile iOS device');
        return;
      }
      _showLockScreen(source: "postFrameInit");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.2,
                  child: Image.asset('assets/loading_photos_background.png'),
                ),
                SizedBox(
                  width: 180,
                  child: GradientButton(
                    text: context.l10n.unlock,
                    iconData: Icons.lock_open_outlined,
                    onTap: () async {
                      _showLockScreen(source: "tapUnlock");
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isNonMobileIOSDevice() {
    if (Platform.isAndroid) {
      return false;
    }
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600 ? true : false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.info(state.toString());
    if (state == AppLifecycleState.resumed && !_isShowingLockScreen) {
      // This is triggered either when the lock screen is dismissed or when
      // the app is brought to foreground
      _hasPlacedAppInBackground = false;
      final bool didAuthInLast5Seconds = lastAuthenticatingTime != null &&
          DateTime.now().millisecondsSinceEpoch - lastAuthenticatingTime! <
              5000;
      if (!_hasAuthenticationFailed && !didAuthInLast5Seconds) {
        // Show the lock screen again only if the app is resuming from the
        // background, and not when the lock screen was explicitly dismissed
        Future.delayed(
          Duration.zero,
          () => _showLockScreen(source: "lifeCycle"),
        );
      } else {
        _hasAuthenticationFailed = false; // Reset failure state
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // This is triggered either when the lock screen pops up or when
      // the app is pushed to background
      if (!_isShowingLockScreen) {
        _hasPlacedAppInBackground = true;
        _hasAuthenticationFailed = false; // reset failure state
      }
    }
  }

  @override
  void dispose() {
    _logger.info('disposing');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _showLockScreen({String source = ''}) async {
    final int id = DateTime.now().millisecondsSinceEpoch;
    _logger.info("Showing lock screen $source $id");
    try {
      _isShowingLockScreen = true;
      final result = await requestAuthentication(
        context,
        context.l10n.authToViewSecrets,
      );
      _logger.finest("LockScreen Result $result $id");
      _isShowingLockScreen = false;
      if (result) {
        lastAuthenticatingTime = DateTime.now().millisecondsSinceEpoch;
        AppLock.of(context)!.didUnlock();
      } else {
        if (!_hasPlacedAppInBackground) {
          // Treat this as a failure only if user did not explicitly
          // put the app in background
          _hasAuthenticationFailed = true;
          _logger.info("Authentication failed");
        }
      }
    } catch (e, s) {
      _isShowingLockScreen = false;
      _logger.severe(e, s);
    }
  }
}
