import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:ente_auth/core/utils/dialog_util.dart';
import 'package:ente_auth/data/models/code.dart';
import 'package:ente_auth/data/store/code_store.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/theme.dart';
import 'package:ente_auth/ui/page/settings/import/import_success.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class PlainTextImport extends StatelessWidget {
  const PlainTextImport({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          l10n.importInstruction,
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          color: Theme.of(context).colorScheme.gNavBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "otpauth://totp/provider.com:you@email.com?secret=YOUR_SECRET",
              style: TextStyle(
                fontFeatures: const [FontFeature.tabularFigures()],
                fontFamily: Platform.isIOS ? "Courier" : "monospace",
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(l10n.importCodeDelimiterInfo),
      ],
    );
  }

}


Future<void> showImportInstructionDialog(BuildContext context) async {
  final l10n = context.l10n;
  final AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    title: Text(
      l10n.importCodes,
      style: Theme.of(context).textTheme.titleLarge,
    ),
    content: const SingleChildScrollView(
      child: PlainTextImport(),
    ),
    actions: [
      TextButton(
        child: Text(
          l10n.cancel,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
      ),
      TextButton(
        child: Text(l10n.selectFile),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          _pickImportFile(context);
        },
      ),
    ],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
    barrierColor: Colors.black12,
  );
}


Future<void> _pickImportFile(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null) {
    return;
  }
  try {
    File file = File(result.files.single.path!);
    final codes = await file.readAsString();
    List<String> splitCodes = codes.split(",");
    if (splitCodes.length == 1) {
      splitCodes = codes.split("\n");
    }
    final parsedCodes = [];
    for (final code in splitCodes) {
      try {
        parsedCodes.add(Code.fromRawData(code));
      } catch (e) {
        Logger('PlainText').severe("Could not parse code", e);
      }
    }
    for (final code in parsedCodes) {
      await CodeStore.instance.addCode(code, shouldSync: false);
    }
    await importSuccessDialog(context, parsedCodes.length);
  } catch (e) {
    await showErrorDialog(
      context,
      context.l10n.sorry,
      context.l10n.importFailureDesc,
    );
  }
}
