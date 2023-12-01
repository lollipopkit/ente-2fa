import 'dart:math';

import "package:ente_auth/l10n/l10n.dart";
import 'package:ente_auth/models/code.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import "package:flutter/material.dart";
import 'package:qr_flutter/qr_flutter.dart';

class ViewQrPage extends StatelessWidget {
  final Code? code;

  const ViewQrPage({this.code, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double qrSize = min(screenWidth - 80, 300.0);
    final enteTextTheme = getEnteTextTheme(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrCode),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 20,
              ),
              QrImageView(
                data: code?.rawData ?? '',
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                version: QrVersions.auto,
                size: qrSize,
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.account,
                        style: enteTextTheme.largeMuted,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        code?.account ?? '',
                        style: enteTextTheme.largeBold,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.codeIssuerHint,
                        style: enteTextTheme.largeMuted,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        code?.issuer ?? '',
                        style: enteTextTheme.largeBold,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
