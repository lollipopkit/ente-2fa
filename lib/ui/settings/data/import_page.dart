import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:ente_auth/ui/components/title_bar_title_widget.dart';
import 'package:ente_auth/ui/components/title_bar_widget.dart';
import 'package:ente_auth/ui/settings/data/import/import_service.dart';
import 'package:flutter/material.dart';

enum ImportType {
  plainText,
  encrypted,
  ravio,
  googleAuthenticator,
  aegis,
  twoFas,
  bitwarden,
}

class ImportCodePage extends StatelessWidget {
  static const List<ImportType> importOptions = [
    ImportType.plainText,
    ImportType.encrypted,
    ImportType.twoFas,
    ImportType.aegis,
    ImportType.bitwarden,
    ImportType.googleAuthenticator,
    ImportType.ravio,
  ];

  const ImportCodePage({super.key});

  String _getTitle(BuildContext context, ImportType type) {
    switch (type) {
      case ImportType.plainText:
        return context.l10n.importTypePlainText;
      case ImportType.encrypted:
        return context.l10n.importTypeEnteEncrypted;
      case ImportType.ravio:
        return 'Raivo OTP';
      case ImportType.googleAuthenticator:
        return 'Google Authenticator';
      case ImportType.aegis:
        return 'Aegis Authenticator';
      case ImportType.twoFas:
        return '2FAS Authenticator';
      case ImportType.bitwarden:
        return 'Bitwarden';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          TitleBarWidget(
            flexibleSpaceTitle: TitleBarTitleWidget(
              title: context.l10n.importCodes,
            ),
            flexibleSpaceCaption: "Import source",
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (delegateBuildContext, index) {
                if (index == 0) {
                  return const SizedBox(height: 37);
                }
                index--;
                final type = importOptions[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3),
                  child: ListTile(
                    title: Text(_getTitle(context, type)),
                    tileColor: getEnteColorScheme(context).fillFaint,
                    selectedColor: getEnteColorScheme(context).fillFaint,
                    trailing: const Icon(Icons.chevron_right_outlined),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    // isBottomBorderRadiusRemoved:
                    //     index != importOptions.length - 1,
                    // isTopBorderRadiusRemoved: index != 0,
                    onTap: () async {
                      ImportService().initiateImport(context, type);
                      // routeToPage(context, ImportCodePage());
                      // _showImportInstructionDialog(context);
                    },
                  ),
                );
              },
              childCount: importOptions.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}
