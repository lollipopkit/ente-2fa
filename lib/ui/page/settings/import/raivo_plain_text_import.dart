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
import 'package:flutter/material.dart';

Future<void> showRaivoImportInstruction(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialogWidget(
    context: context,
    title: l10n.importFromApp("Raivo OTP"),
    body: l10n.importRaivoGuide,
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
      await _pickRaivoJsonFile(context);
    } else {}
  }
}

Future<void> _pickRaivoJsonFile(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null) {
    return;
  }
  try {
    String path = result.files.single.path!;
    int? count = await _processRaivoExportFile(context, path);
    if (count != null) {
      await importSuccessDialog(context, count);
    }
  } catch (e) {
    await showErrorDialog(
      context,
      context.l10n.sorry,
      context.l10n.importFailureDesc,
    );
  }
}

Future<int?> _processRaivoExportFile(BuildContext context, String path) async {
  File file = File(path);
  if (path.endsWith('.zip')) {
    await showErrorDialog(
      context,
      context.l10n.sorry,
      "We don't support zip files yet. Please unzip the file and try again.",
    );
    return null;
  }
  final jsonString = await file.readAsString();
  List<dynamic> jsonArray = jsonDecode(jsonString);
  final parsedCodes = [];
  for (var item in jsonArray) {
    var kind = item['kind'];
    var algorithm = item['algorithm'];
    var timer = item['timer'];
    var digits = item['digits'];
    var issuer = item['issuer'];
    var secret = item['secret'];
    var account = item['account'];
    var counter = item['counter'];

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
