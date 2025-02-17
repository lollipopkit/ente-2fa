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

Future<void> showBitwardenImportInstruction(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialogWidget(
    context: context,
    title: l10n.importFromApp("Bitwarden"),
    body: l10n.importBitwardenGuide,
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
      await _pickBitwardenJsonFile(context);
    }
  }
}

Future<void> _pickBitwardenJsonFile(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null) {
    return;
  }
  try {
    String path = result.files.single.path!;
    int? count = await _processBitwardenExportFile(context, path);
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

Future<int?> _processBitwardenExportFile(
  BuildContext context,
  String path,
) async {
  File file = File(path);
  final jsonString = await file.readAsString();
  final data = jsonDecode(jsonString);
  List<dynamic> jsonArray = data['items'];
  final parsedCodes = [];
  for (var item in jsonArray) {
    if (item['login']['totp'] != null) {
      var issuer = item['name'];
      var account = item['login']['username'];
      var secret = item['login']['totp'];

      parsedCodes.add(
        Code.fromAccountAndSecret(
          account,
          issuer,
          secret,
        ),
      );
    }
  }

  for (final code in parsedCodes) {
    await CodeStore.instance.addCode(code, shouldSync: false);
  }
  return parsedCodes.length;
}
