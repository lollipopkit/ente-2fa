import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:ente_auth/core/event_bus.dart';
import 'package:ente_auth/core/events/codes_updated_event.dart';
import 'package:ente_auth/data/models/code.dart';
import 'package:ente_auth/data/services/auth.dart';
import 'package:logging/logging.dart';

class CodeStore {
  static final CodeStore instance = CodeStore._privateConstructor();

  CodeStore._privateConstructor();

  late AuthenticatorService _authenticatorService;
  final _logger = Logger("CodeStore");

  Future<void> init() async {
    _authenticatorService = AuthenticatorService.instance;
  }

  Future<List<Code>> getAllCodes() async {
    final entities = await _authenticatorService.getEntities();
    final List<Code> codes = [];
    for (final entity in entities) {
      final decodeJson = jsonDecode(entity.rawData);
      final code = Code.fromRawData(decodeJson);
      code.generatedID = entity.generatedID;
      code.hasSynced = entity.hasSynced;
      codes.add(code);
    }

    // sort codes by issuer,account
    codes.sort((a, b) {
      final issuerComparison = compareAsciiLowerCaseNatural(a.issuer, b.issuer);
      if (issuerComparison != 0) {
        return issuerComparison;
      }
      return compareAsciiLowerCaseNatural(a.account, b.account);
    });
    return codes;
  }

  Future<AddResult> addCode(
    Code code, {
    bool shouldSync = true,
  }) async {
    final codes = await getAllCodes();
    bool isExistingCode = false;
    for (final existingCode in codes) {
      if (existingCode == code) {
        _logger.info("Found duplicate code, skipping add");
        return AddResult.duplicate;
      } else if (existingCode.generatedID == code.generatedID) {
        isExistingCode = true;
        break;
      }
    }
    late AddResult result;
    if (isExistingCode) {
      result = AddResult.updateCode;
      await _authenticatorService.updateEntry(
        code.generatedID!,
        jsonEncode(code.rawData),
        shouldSync,
      );
    } else {
      result = AddResult.newCode;
      code.generatedID = await _authenticatorService.addEntry(
        jsonEncode(code.rawData),
        shouldSync,
      );
    }
    Bus.instance.fire(CodesUpdatedEvent());
    return result;
  }

  Future<void> removeCode(Code code) async {
    await _authenticatorService.deleteEntry(code.generatedID!);
    Bus.instance.fire(CodesUpdatedEvent());
  }
}

enum AddResult {
  newCode,
  duplicate,
  updateCode,
}
