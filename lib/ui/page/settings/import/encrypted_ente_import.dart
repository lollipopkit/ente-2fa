import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ente_auth/core/utils/crypto_util.dart';
import 'package:ente_auth/core/utils/dialog_util.dart';
import 'package:ente_auth/core/utils/toast_util.dart';
import 'package:ente_auth/data/models/code.dart';
import 'package:ente_auth/data/models/export/ente.dart';
import 'package:ente_auth/data/store/code_store.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/ui/page/settings/import/import_success.dart';
import 'package:ente_auth/ui/view/buttons/button_widget.dart';
import 'package:ente_auth/ui/view/buttons/models/button_type.dart';
import 'package:ente_auth/ui/view/dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:logging/logging.dart';

Future<void> showEncryptedImportInstruction(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialogWidget(
    context: context,
    title: l10n.importFromApp("ente Auth"),
    body: l10n.importEnteEncGuide,
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
      await _pickEnteJsonFile(context);
    } else {}
  }
}

Future<void> _decryptExportData(
  BuildContext context,
  EnteAuthExport enteAuthExport, {
  String? password,
}) async {
  final l10n = context.l10n;
  bool isPasswordIncorrect = false;
  int? importedCodeCount;
  await showTextInputDialog(
    context,
    title: l10n.passwordForDecryptingExport,
    submitButtonLabel: l10n.importLabel,
    hintText: l10n.enterYourPasswordHint,
    isPasswordInput: true,
    alwaysShowSuccessState: false,
    showOnlyLoadingState: true,
    onSubmit: (String password) async {
      if (password.isEmpty) {
        showToast(context, l10n.passwordEmptyError);
        Future.delayed(const Duration(seconds: 0), () {
          _decryptExportData(context, enteAuthExport, password: password);
        });
        return;
      }
      if (password.isNotEmpty) {
        try {
          final derivedKey = await CryptoUtil.deriveKey(
            utf8.encode(password),
            Sodium.base642bin(enteAuthExport.kdfParams.salt),
            enteAuthExport.kdfParams.memLimit,
            enteAuthExport.kdfParams.opsLimit,
          );
          Uint8List? decryptedContent;
          // Encrypt the key with this derived key
          try {
            decryptedContent = await CryptoUtil.decryptChaCha(
              Sodium.base642bin(enteAuthExport.encryptedData),
              derivedKey,
              Sodium.base642bin(enteAuthExport.encryptionNonce),
            );
          } catch (e, s) {
            Logger("encryptedImport").warning('failed to decrypt', e, s);
            showToast(context, l10n.incorrectPasswordTitle);
            isPasswordIncorrect = true;
          }
          if (isPasswordIncorrect) {
            Future.delayed(const Duration(seconds: 0), () {
              _decryptExportData(context, enteAuthExport, password: password);
            });
            return;
          }
          final content = await compute(utf8.decode, decryptedContent!);
          List<String> splitCodes = content.split("\n");
          final parsedCodes = [];
          for (final code in splitCodes) {
            try {
              parsedCodes.add(await compute(Code.fromRawData, code));
            } catch (e) {
              Logger('EncryptedText').severe("Could not parse code", e);
            }
          }
          for (final code in parsedCodes) {
            await CodeStore.instance.addCode(code, shouldSync: false);
          }
          importedCodeCount = parsedCodes.length;
        } catch (e, s) {
          Logger("ExportWidget").severe(e, s);
          showToast(context, "Error while exporting codes.");
        }
      }
    },
  );
  if (importedCodeCount != null) {
    await importSuccessDialog(context, importedCodeCount!);
  }
}

Future<void> _pickEnteJsonFile(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null) {
    return;
  }

  try {
    File file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final decoded = await compute(jsonDecode, jsonString);
    final exportedData = EnteAuthExport.fromJson(decoded);
    await _decryptExportData(context, exportedData);
  } catch (e) {
    await showErrorDialog(
      context,
      context.l10n.sorry,
      context.l10n.importFailureDesc,
    );
  }
}
