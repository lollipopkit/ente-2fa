import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';

import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/models/code.dart';
import 'package:ente_auth/store/code_store.dart';
import 'package:ente_auth/ui/components/buttons/button_widget.dart';
import 'package:ente_auth/ui/components/dialog_widget.dart';
import 'package:ente_auth/ui/components/models/button_type.dart';
import 'package:ente_auth/ui/settings/data/import/import_success.dart';
import 'package:ente_auth/utils/dialog_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/gcm.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';
import 'package:pointycastle/pointycastle.dart';

Future<void> showAegisImportInstruction(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialogWidget(
    context: context,
    title: l10n.importFromApp("Aegis Authenticator"),
    body: l10n.importAegisGuide,
    buttons: [
      ButtonWidget(
        buttonType: ButtonType.primary,
        labelText: l10n.importSelectJsonFile,
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
      await _pickAegisJsonFile(context);
    } else {}
  }
}

Future<void> _pickAegisJsonFile(BuildContext context) async {
  final l10n = context.l10n;
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(dialogTitle: l10n.importSelectJsonFile);
  if (result == null) {
    return;
  }
  try {
    String path = result.files.single.path!;
    int? count = await _processAegisExportFile(context, path);
    if (count != null) {
      await importSuccessDialog(context, count);
    }
  } catch (e, s) {
    Logger('AegisImport').severe('exception while processing for aegis', e, s);
    await showErrorDialog(
      context,
      context.l10n.sorry,
      context.l10n.importFailureDesc,
    );
  }
}

Future<int?> _processAegisExportFile(
  BuildContext context,
  String path,
) async {
  File file = File(path);

  final jsonString = await file.readAsString();
  final decodedJson = jsonDecode(jsonString);
  final isEncrypted = decodedJson['header']['slots'] != null;
  dynamic aegisDB;
  if (isEncrypted) {
    String? password;
    try {
      await showTextInputDialog(
        context,
        title: "Enter password to aegis vault",
        submitButtonLabel: "Submit",
        isPasswordInput: true,
        onSubmit: (value) async {
          password = value;
        },
      );
      if (password == null) {
        return null;
      }
      final content = decryptAegisVault(decodedJson, password: password!);
      aegisDB = jsonDecode(content);
    } catch (e, s) {
      Logger("AegisImport")
          .warning("exception while decrypting aegis vault", e, s);
      if (password != null) {
        await showErrorDialog(
          context,
          "Failed to decrypt aegis vault",
          "Please check your password and try again.",
        );
      }
      return null;
    }
  } else {
    aegisDB = decodedJson['db'];
  }
  final parsedCodes = [];
  for (var item in aegisDB['entries']) {
    var kind = item['type'];
    var account = item['name'];
    var issuer = item['issuer'];
    var algorithm = item['info']['algo'];
    var secret = item['info']['secret'];
    var timer = item['info']['period'];
    var digits = item['info']['digits'];

    var counter = item['info']['counter'];

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

String decryptAegisVault(dynamic data, {required String password}) {
  final header = data["header"];
  final slots =
      (header["slots"] as List).where((slot) => slot["type"] == 1).toList();

  Uint8List? masterKey;
  for (final slot in slots) {
    final salt = Uint8List.fromList(hex.decode(slot["salt"]));
    final int iterations = slot["n"];
    final int r = slot["r"];
    final int p = slot["p"];
    const int derivedKeyLength = 32;
    final script = Scrypt()
      ..init(
        ScryptParameters(
          iterations,
          r,
          p,
          derivedKeyLength,
          salt,
        ),
      );

    final key = script.process(Uint8List.fromList(utf8.encode(password)));

    final params = slot["key_params"];
    final nonce = Uint8List.fromList(hex.decode(params["nonce"]));
    final encryptedKeyWithTag =
        Uint8List.fromList(hex.decode(slot["key"]) + hex.decode(params["tag"]));

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(key),
          128,
          nonce,
          Uint8List.fromList(<int>[]),
        ),
      );

    try {
      masterKey = cipher.process(encryptedKeyWithTag);
      break;
    } catch (e) {
      // Ignore decryption failure and continue to next slot
    }
  }

  if (masterKey == null) {
    throw Exception("Unable to decrypt the master key with the given password");
  }

  final content = base64.decode(data["db"]);
  final params = header["params"];
  final nonce = Uint8List.fromList(hex.decode(params["nonce"]));
  final tag = Uint8List.fromList(hex.decode(params["tag"]));
  final cipherTextWithTag = Uint8List.fromList(content + tag);

  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false,
      AEADParameters(
        KeyParameter(masterKey),
        128,
        nonce,
        Uint8List.fromList(<int>[]),
      ),
    );

  final dbBytes = cipher.process(cipherTextWithTag);
  return utf8.decode(dbBytes);
}
