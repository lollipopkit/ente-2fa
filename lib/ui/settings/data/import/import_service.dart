import 'package:ente_auth/ui/settings/data/import/2fas_import.dart';
import 'package:ente_auth/ui/settings/data/import/aegis_import.dart';
import 'package:ente_auth/ui/settings/data/import/bitwarden_import.dart';
import 'package:ente_auth/ui/settings/data/import/encrypted_ente_import.dart';
import 'package:ente_auth/ui/settings/data/import/google_auth_import.dart';
import 'package:ente_auth/ui/settings/data/import/plain_text_import.dart';
import 'package:ente_auth/ui/settings/data/import/raivo_plain_text_import.dart';
import 'package:ente_auth/ui/settings/data/import_page.dart';
import 'package:flutter/material.dart';

class ImportService {
  static final ImportService _instance = ImportService._internal();

  factory ImportService() => _instance;

  ImportService._internal();

  Future<void> initiateImport(BuildContext context, ImportType type) async {
    switch (type) {
      case ImportType.plainText:
        showImportInstructionDialog(context);
        break;
      case ImportType.encrypted:
        showEncryptedImportInstruction(context);
        break;
      case ImportType.ravio:
        showRaivoImportInstruction(context);
        break;
      case ImportType.googleAuthenticator:
        showGoogleAuthInstruction(context);
        break;
      case ImportType.aegis:
        showAegisImportInstruction(context);
        break;
      case ImportType.twoFas:
        show2FasImportInstruction(context);
        break;
      case ImportType.bitwarden:
        showBitwardenImportInstruction(context);
        break;
    }
  }
}
