// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ente_auth/core/utils/dialog_util.dart';
import 'package:ente_auth/data/models/code.dart';
import 'package:ente_auth/data/store/code.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/ui/page/settings/import/import_success.dart';
import 'package:ente_auth/ui/view/buttons/button_type.dart';
import 'package:ente_auth/ui/view/buttons/button_widget.dart';
import 'package:ente_auth/ui/view/dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/export.dart';

Future<void> show2FasImportInstruction(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialogWidget(
    context: context,
    title: l10n.importFromApp("2FAS Authenticator"),
    body: l10n.import2FasGuide,
    buttons: [
      ButtonWidget(
        buttonType: ButtonType.primary,
        labelText: l10n.importSelectAppExport("2FAS Authenticator"),
        isInAlert: true,
        buttonSize: ButtonSize.large,
        buttonAction: ButtonAction.first,
      ),
      ButtonWidget(
        buttonType: ButtonType.secondary,
        labelText: context.l10n.cancel,
        buttonSize: ButtonSize.large,
        isInAlert: true,
        buttonAction: ButtonAction.second,
      ),
    ],
  );
  if (result?.action != null && result!.action != ButtonAction.cancel) {
    if (result.action == ButtonAction.first) {
      await _pick2FasFile(context);
    } else {}
  }
}

Future<void> _pick2FasFile(BuildContext context) async {
  final l10n = context.l10n;
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(dialogTitle: l10n.importSelectJsonFile);
  if (result == null) {
    return;
  }
  try {
    String path = result.files.single.path!;
    int? count = await _process2FasExportFile(context, path);
    if (count != null) {
      await importSuccessDialog(context, count);
    }
  } catch (e, s) {
    Logger('2FASImport').severe('exception while processing import', e, s);
    await showErrorDialog(
      context,
      context.l10n.sorry,
      context.l10n.importFailureDesc,
    );
  }
}

Future<int?> _process2FasExportFile(
  BuildContext context,
  String path,
) async {
  File file = File(path);

  final jsonString = await file.readAsString();
  final decodedJson = await compute(jsonDecode, jsonString);
  int version = (decodedJson['schemaVersion'] ?? 0) as int;
  if (version != 3 && version != 4) {
    // todo: extract strings for l10n. Use same naming format as in aegis
    // to avoid duplicate translation efforts.
    await showErrorDialog(
      context,
      'Unsupported format: $version',
      version == 0
          ? "The selected file is not a valid 2FAS Authenticator export."
          : "Sorry, the app doesn't support this version of 2FAS Authenticator export",
    );
    return null;
  }

  var decodedServices = decodedJson['services'];
  // https://github.com/twofas/2fas-android/blob/e97f1a1040eafaed6d5284d54d33403dff215886/data/services/src/main/java/com/twofasapp/data/services/domain/BackupContent.kt#L39
  final isEncrypted = decodedJson['reference'] != null;
  if (isEncrypted) {
    String? password;
    try {
      await showTextInputDialog(
        context,
        title: "Enter password to decrypt 2FAS backup",
        submitButtonLabel: "Submit",
        isPasswordInput: true,
        onSubmit: (value) async {
          password = value;
        },
      );
      if (password == null) {
        return null;
      }
      final content = await compute(
        decrypt2FasVault,
        {"json": decodedJson, "password": password},
      );
      decodedServices = await compute(jsonDecode, content);
    } catch (e, s) {
      Logger("2FASImport").warning("exception while decrypting backup", e, s);
      if (password != null) {
        await showErrorDialog(
          context,
          "Failed to decrypt 2Fas export",
          "Please check your password and try again.",
        );
      }
      return null;
    }
  }
  final parsedCodes = [];
  for (var item in decodedServices) {
    var kind = item['otp']['tokenType'];
    var account = item['otp']['account'] ?? '';
    var issuer = item['otp']['issuer'] ?? item['name'] ?? '';
    var algorithm = item['otp']['algorithm'];
    var secret = item['secret'];
    var timer = item['otp']['period'];
    var digits = item['otp']['digits'];
    var counter = item['otp']['counter'];

    // Build the OTP URL
    String otpUrl;

    if (kind.toLowerCase() == 'totp') {
      otpUrl =
          'otpauth://$kind/$issuer:$account?secret=$secret&issuer=$issuer&algorithm=$algorithm&digits=$digits&period=$timer';
    } else if (kind.toLowerCase() == 'hotp') {
      otpUrl =
          'otpauth://$kind/$issuer:$account?secret=$secret&issuer=$issuer&algorithm=$algorithm&digits=$digits&counter=$counter';
    } else {
      throw Exception('Invalid OTP type');
    }
    parsedCodes.add(Code.fromRawData(otpUrl));
  }

  for (final code in parsedCodes) {
    await CodeStore.instance.addCode(code, shouldSync: false);
  }
  int count = parsedCodes.length;
  return count;
}

String decrypt2FasVault(Map<String, dynamic> param) {
  final data = param['json'];
  final password = param['password'];
  int iterationCount = 10000;
  int keySize = 256;
  final String encryptedServices = data["servicesEncrypted"];
  var split = encryptedServices.split(":");
  final encryptedData = base64.decode(split[0]);
  final salt = base64.decode(split[1]);
  final iv = base64.decode(split[2]);
  // derive 256 key using PBKDF2WithHmacSHA256 and 10000 iterations and above salt
  final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  final params = Pbkdf2Parameters(
    salt,
    iterationCount,
    keySize ~/ 8,
  );
  pbkdf2.init(params);
  Uint8List key = Uint8List(keySize ~/ 8);
  pbkdf2.deriveKey(Uint8List.fromList(utf8.encode(password)), 0, key, 0);
  final decrypted = decrypt(key, iv, encryptedData);
  final utf8Decode = utf8.decode(decrypted);
  return utf8Decode;
}

Uint8List decrypt(Uint8List key, Uint8List iv, Uint8List data) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false,
      AEADParameters(
        KeyParameter(key),
        128,
        iv,
        Uint8List.fromList(<int>[]),
      ),
    );

  final dbBytes = cipher.process(data);
  return dbBytes;
}
