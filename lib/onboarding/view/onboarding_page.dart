import 'dart:async';

import 'package:ente_auth/app/app.dart';
import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/ente_theme_data.dart';
import "package:ente_auth/l10n/l10n.dart";
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/ui/home_page.dart';
import 'package:ente_auth/ui/settings/language_picker.dart';
import 'package:ente_auth/utils/navigation_util.dart';
import 'package:ente_auth/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:local_auth/local_auth.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    debugPrint("Building OnboardingPage");
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints.tightFor(height: 800, width: 450),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40),
                child: Column(
                  children: [
                    Column(
                      children: [
                        kDebugMode
                            ? GestureDetector(
                                child: const Align(
                                  alignment: Alignment.topRight,
                                  child: Text("Lang"),
                                ),
                                onTap: () async {
                                  final locale = await getLocale();
                                  routeToPage(
                                    context,
                                    LanguageSelectorPage(
                                      appSupportedLocales,
                                      (locale) async {
                                        await setLocale(locale);
                                        App.setLocale(context, locale);
                                      },
                                      locale,
                                    ),
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                              )
                            : const SizedBox(),
                        Image.asset(
                          "assets/sheild-front-gradient.png",
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "ente",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 42,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Authenticator",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l10n.onBoardingBody,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.white38,
                                    // color: Theme.of(context)
                                    //                            .colorScheme
                                    //                            .mutedTextColor,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Hero(
                        tag: "use_offline",
                        child: ElevatedButton(
                          style: Theme.of(context)
                              .colorScheme
                              .optionalActionButtonStyle,
                          onPressed: _optForOfflineMode,
                          child: Text(
                            l10n.useOffline,
                            style: const TextStyle(
                              color: Colors.black, // same for both themes
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _optForOfflineMode() async {
    bool canCheckBio = await LocalAuthentication().canCheckBiometrics;
    if(!canCheckBio) {
      showToast(context, "Sorry, biometric authentication is not supported on this device.");
      return;
    }
    final bool hasOptedBefore = Configuration.instance.hasOptedForOfflineMode();
    if (!hasOptedBefore) {
      await Configuration.instance.optForOfflineMode();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const HomePage();
          },
        ),
      );
    }
  }
}
