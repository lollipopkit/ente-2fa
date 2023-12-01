import 'package:ente_auth/core/utils/toast_util.dart';
import 'package:ente_auth/data/models/code.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/ui/page/settings/import/google_auth_import.dart';
import 'package:ente_auth/ui/view/scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerGoogleAuthPage extends StatefulWidget {
  const ScannerGoogleAuthPage({super.key});

  @override
  State<ScannerGoogleAuthPage> createState() => ScannerGoogleAuthPageState();
}

class ScannerGoogleAuthPageState extends State<ScannerGoogleAuthPage> {
  String? totp;
  late Size size;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scan),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                facing: CameraFacing.back,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                final raw = barcodes
                    .where((element) => element.rawValue != null)
                    .map((e) => e.rawValue!)
                    .toList()
                    .firstOrNull;
                if (raw != null && raw.startsWith(kGoogleAuthExportPrefix)) {
                  List<Code> codes = parseGoogleAuth(raw);
                  Navigator.of(context).pop(codes);
                } else {
                  showToast(context, "Invalid QR code");
                }
              },
              overlay: CustomPaint(
                painter: ScannerOverlay(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width * 0.77,
                    height: size.width * 0.77,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (totp != null) ? Text(totp!) : Text(l10n.scanACode),
            ),
          ),
        ],
      ),
    );
  }
}
