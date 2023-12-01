import 'dart:convert';
import 'dart:io';

import 'package:ente_auth/app.dart';
import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/core/utils/crypto_util.dart';
import 'package:ente_auth/core/utils/dialog_util.dart';
import 'package:ente_auth/core/utils/navigation_util.dart';
import 'package:ente_auth/core/utils/toast_util.dart';
import 'package:ente_auth/data/const/theme/colors.dart';
import 'package:ente_auth/data/const/theme/ente_theme.dart';
import 'package:ente_auth/data/models/export/ente.dart';
import 'package:ente_auth/data/services/local_authentication_service.dart';
import 'package:ente_auth/data/services/preference_service.dart';
import 'package:ente_auth/data/store/code_store.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/ui/page/settings/import/import.dart';
import 'package:ente_auth/ui/page/settings/language.dart';
import 'package:ente_auth/ui/view/buttons/button_widget.dart';
import 'package:ente_auth/ui/view/buttons/models/button_type.dart';
import 'package:ente_auth/ui/view/cardx.dart';
import 'package:ente_auth/ui/view/dialog.dart';
import 'package:ente_auth/ui/view/expand_tile.dart';
import 'package:ente_auth/ui/view/switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';
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
                await _handleExportClick(context);
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

Future<void> _handleExportClick(BuildContext context) async {
  final result = await showDialogWidget(
    context: context,
    title: context.l10n.selectExportFormat,
    body: context.l10n.exportDialogDesc,
    buttons: [
      ButtonWidget(
        buttonType: ButtonType.primary,
        labelText: context.l10n.encrypted,
        isInAlert: true,
        buttonSize: ButtonSize.large,
        buttonAction: ButtonAction.first,
      ),
      ButtonWidget(
        buttonType: ButtonType.secondary,
        labelText: context.l10n.plainText,
        buttonSize: ButtonSize.large,
        isInAlert: true,
        buttonAction: ButtonAction.second,
      ),
    ],
  );
  if (result?.action != null && result!.action != ButtonAction.cancel) {
    if (result.action == ButtonAction.first) {
      await _requestForEncryptionPassword(context);
    } else {
      await _showExportWarningDialog(context);
    }
  }
}

Future<void> _requestForEncryptionPassword(
  BuildContext context, {
  String? password,
}) async {
  final l10n = context.l10n;
  await showTextInputDialog(
    context,
    title: l10n.passwordToEncryptExport,
    submitButtonLabel: l10n.export,
    hintText: l10n.enterPassword,
    isPasswordInput: true,
    alwaysShowSuccessState: false,
    onSubmit: (String password) async {
      if (password.isEmpty || password.length < 4) {
        showToast(context, "Password must be at least 4 characters long.");
        Future.delayed(const Duration(seconds: 0), () {
          _requestForEncryptionPassword(context, password: password);
        });
        return;
      }
      if (password.isNotEmpty) {
        try {
          final kekSalt = CryptoUtil.getSaltToDeriveKey();
          final derivedKeyResult = await CryptoUtil.deriveSensitiveKey(
            utf8.encode(password),
            kekSalt,
          );
          String exportPlainText = await _getAuthDataForExport();
          // Encrypt the key with this derived key
          final encResult = await CryptoUtil.encryptChaCha(
            utf8.encode(exportPlainText),
            derivedKeyResult.key,
          );
          final encContent = Sodium.bin2base64(encResult.encryptedData!);
          final encNonce = Sodium.bin2base64(encResult.header!);
          final data = EnteAuthExport(
            version: 1,
            encryptedData: encContent,
            encryptionNonce: encNonce,
            kdfParams: KDFParams(
              memLimit: derivedKeyResult.memLimit,
              opsLimit: derivedKeyResult.opsLimit,
              salt: Sodium.bin2base64(kekSalt),
            ),
          );
          // get json value of data
          _exportCodes(context, jsonEncode(data.toJson()));
        } catch (e, s) {
          Logger("Export").severe(e, s);
          showToast(context, "Error while exporting codes.");
        }
      }
    },
  );
}

Future<void> _showExportWarningDialog(BuildContext context) async {
  await showChoiceDialog(
    context,
    title: context.l10n.warning,
    body: context.l10n.exportWarningDesc,
    isCritical: true,
    firstButtonOnTap: () async {
      final data = await _getAuthDataForExport();
      await _exportCodes(context, data);
    },
    secondButtonLabel: context.l10n.cancel,
    firstButtonLabel: context.l10n.iUnderStand,
  );
}

Future<void> _exportCodes(BuildContext context, String fileContent) async {
  final codeFile = File(
    "${Configuration.instance.getTempDirectory()}ente-authenticator-codes.txt",
  );
  final hasAuthenticated = await LocalAuthenticationService.instance
      .requestLocalAuthentication(context, context.l10n.authToExportCodes);
  if (!hasAuthenticated) {
    return;
  }
  if (codeFile.existsSync()) {
    await codeFile.delete();
  }
  codeFile.writeAsStringSync(fileContent);
  final Size size = MediaQuery.of(context).size;
  await Share.shareXFiles(
    [codeFile.path].map((e) => XFile(e)).toList(),
    sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
  );
  Future.delayed(const Duration(seconds: 15), () async {
    if (codeFile.existsSync()) {
      codeFile.deleteSync();
    }
  });
}

Future<String> _getAuthDataForExport() async {
  final codes = await CodeStore.instance.getAllCodes();
  String data = "";
  for (final code in codes) {
    data += "${code.rawData}\n";
  }
  return data;
}