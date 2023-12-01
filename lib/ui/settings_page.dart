import 'dart:io';

import 'package:ente_auth/app/app.dart';
import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/services/local_authentication_service.dart';
import 'package:ente_auth/services/preference_service.dart';
import 'package:ente_auth/theme/colors.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:ente_auth/ui/components/cardx.dart';
import 'package:ente_auth/ui/components/expand_tile.dart';
import 'package:ente_auth/ui/components/toggle_switch_widget.dart';
import 'package:ente_auth/ui/settings/data/export_widget.dart';
import 'package:ente_auth/ui/settings/data/import_page.dart';
import 'package:ente_auth/ui/settings/language_picker.dart';
import 'package:ente_auth/utils/navigation_util.dart';
import 'package:ente_auth/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enteColorScheme = getEnteColorScheme(context);
    return Scaffold(
      body: Container(
        color: enteColorScheme.backdropBase,
        child: _getBody(context, enteColorScheme),
      ),
    );
  }

  Widget _getBody(BuildContext context, EnteColorScheme colorScheme) {
    final l10n = context.l10n;
    const sectionSpacing = SizedBox(height: 8);
    final List<Widget> contents = [
      sectionSpacing,
      Image.asset('assets/app_icon.png', width: 37, height: 37),
      sectionSpacing,
      const Text('v1.0.0'),
      const SizedBox(height: 37),
      CardX(
        ExpandTile(
          leading: const Icon(Icons.data_usage_outlined),
          title: Text(l10n.data, style: _titleStyle),
          initiallyExpanded: true,
          children: [
            ListTile(
              title: Text(l10n.importCodes),
              trailing: const Icon(Icons.chevron_right_outlined),
              onTap: () async {
                routeToPage(context, const ImportCodePage());
              },
            ),
            ListTile(
              title: Text(l10n.exportCodes),
              trailing: const Icon(Icons.chevron_right_outlined),
              onTap: () async {
                await handleExportClick(context);
              },
            ),
          ],
        ),
      ),
      sectionSpacing,
      CardX(
        ExpandTile(
          title: Text(l10n.general, style: _titleStyle),
          initiallyExpanded: true,
          children: [
            ListTile(
              title: Text(l10n.lockscreen),
              trailing: ToggleSwitchWidget(
                value: () => Configuration.instance.shouldShowLockScreen(),
                onChanged: () async {
                  await LocalAuthenticationService.instance
                      .requestLocalAuthForLockScreen(
                    context,
                    !Configuration.instance.shouldShowLockScreen(),
                    context.l10n.authToChangeLockscreenSetting,
                    context.l10n.lockScreenEnablePreSteps,
                  );
                },
              ),
            ),
            ListTile(
              title: Text(l10n.language),
              selectedColor: getEnteColorScheme(context).fillFaint,
              trailing: const Icon(Icons.chevron_right_outlined),
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
                );
              },
            ),
            ListTile(
              title: Text(l10n.showLargeIcons),
              trailing: ToggleSwitchWidget(
                value: () => PreferenceService.instance.shouldShowLargeIcons(),
                onChanged: () async {
                  await PreferenceService.instance.setShowLargeIcons(
                    !PreferenceService.instance.shouldShowLargeIcons(),
                  );
                },
              ),
            ),
            ExpandTile(
              title: Text(l10n.shouldHideCode),
              trailing: ToggleSwitchWidget(
                value: () => PreferenceService.instance.shouldHideCodes(),
                onChanged: () async {
                  await PreferenceService.instance.setHideCodes(
                    !PreferenceService.instance.shouldHideCodes(),
                  );
                  if (PreferenceService.instance.shouldHideCodes()) {
                    showToast(context, context.l10n.doubleTapToViewHiddenCode);
                  }
                },
              ),
            ),
            ExpandTile(
              title: Text(l10n.focusOnSearchBar),
              trailing: ToggleSwitchWidget(
                value: () =>
                    PreferenceService.instance.shouldAutoFocusOnSearchBar(),
                onChanged: () async {
                  await PreferenceService.instance.setAutoFocusOnSearchBar(
                    !PreferenceService.instance.shouldAutoFocusOnSearchBar(),
                  );
                },
              ),
            ),
            if (Platform.isAndroid)
              ExpandTile(
                title: Text(l10n.minimizeAppOnCopy),
                trailing: ToggleSwitchWidget(
                  value: () =>
                      PreferenceService.instance.shouldMinimizeOnCopy(),
                  onChanged: () async {
                    await PreferenceService.instance.setShouldMinimizeOnCopy(
                      !PreferenceService.instance.shouldMinimizeOnCopy(),
                    );
                  },
                ),
              ),
          ],
          leading: const Icon(Icons.graphic_eq),
        ),
      ),
      sectionSpacing,
      CardX(
        ExpandTile(
          title: Text(l10n.about, style: _titleStyle),
          children: [
            ListTile(
              title: Text(l10n.weAreOpenSource),
              selectedColor: getEnteColorScheme(context).fillFaint,
              trailing: const Icon(Icons.chevron_right_outlined),
              onTap: () async {
                launchUrl(
                  Uri.parse("https://github.com/lollipopkit/ente-2fa"),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ],
          leading: const Icon(Icons.info_outline),
        ),
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: contents,
          ),
        ),
      ),
    );
  }
}
