import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:ente_auth/ui/settings/data/import_page.dart';
import 'package:ente_auth/utils/navigation_util.dart';
import 'package:flutter/material.dart';

class HomeEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onManuallySetupTap;

  const HomeEmptyStateWidget({
    super.key,
    required this.onScanTap,
    required this.onManuallySetupTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 800, width: 450),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 40),
              Text(
                l10n.setupFirstAccount,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 177),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 400,
                    child: OutlinedButton(
                      onPressed: onScanTap,
                      child: Text(l10n.importScanQrCode),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 400,
                    child: OutlinedButton(
                      onPressed: () => routeToPage(context, const ImportCodePage()),
                      child: Text(l10n.importCodes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 54),
              InkWell(
                onTap: onManuallySetupTap,
                child: Text(
                  l10n.importEnterSetupKey,
                  textAlign: TextAlign.center,
                  style: getEnteTextTheme(context)
                      .bodyFaint
                      .copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
