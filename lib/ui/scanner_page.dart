import 'package:ente_auth/models/code.dart';
import 'package:ente_auth/ui/components/scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => ScannerPageState();
}

class ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? totp;
  late Size size;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              final code = Code.fromRawData(
                barcodes
                    .where((element) => element.rawValue != null)
                    .map((e) => e.rawValue!)
                    .toList()
                    .first,
              );
              Navigator.of(context).pop(code);
            },
            fit: BoxFit.cover,
          ),
          CustomPaint(
            painter: ScannerOverlay(
              Rect.fromCenter(
                center: size.center(Offset.zero),
                width: size.width * 0.77,
                height: size.width * 0.77,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
