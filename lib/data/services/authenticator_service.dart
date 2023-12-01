import 'dart:async';
import 'dart:convert';

import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/core/utils/crypto_util.dart';
import 'package:ente_auth/data/models/authenticator/entity_result.dart';
import 'package:ente_auth/data/models/authenticator/local_auth_entity.dart';
import 'package:ente_auth/data/store/offline_authenticator_db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:logging/logging.dart';

class AuthenticatorService {
  final _logger = Logger((AuthenticatorService).toString());
  final _config = Configuration.instance;
  late OfflineAuthenticatorDB _offlineDb;

  AuthenticatorService._privateConstructor();

  static final AuthenticatorService instance =
      AuthenticatorService._privateConstructor();

  Future<void> init() async {
    _offlineDb = OfflineAuthenticatorDB.instance;
  }

  Future<List<EntityResult>> getEntities() async {
    final List<LocalAuthEntity> result = await _offlineDb.getAll();
    final List<EntityResult> entities = [];
    if (result.isEmpty) {
      return entities;
    }
    final key = await getOrCreateAuthDataKey();
    for (LocalAuthEntity e in result) {
      try {
        final decryptedValue = await CryptoUtil.decryptChaCha(
          Sodium.base642bin(e.encryptedData),
          key,
          Sodium.base642bin(e.header),
        );
        final hasSynced = !(e.id == null || e.shouldSync);
        entities.add(
          EntityResult(
            e.generatedID,
            utf8.decode(decryptedValue),
            hasSynced,
          ),
        );
      } catch (e, s) {
        _logger.severe(e, s);
      }
    }
    return entities;
  }

  Future<int> addEntry(
    String plainText,
    bool shouldSync,
  ) async {
    var key = await getOrCreateAuthDataKey();
    final encryptedKeyData = await CryptoUtil.encryptChaCha(
      utf8.encode(plainText),
      key,
    );
    String encryptedData = Sodium.bin2base64(encryptedKeyData.encryptedData!);
    String header = Sodium.bin2base64(encryptedKeyData.header!);
    final insertedID = await _offlineDb.insert(encryptedData, header);
    return insertedID;
  }

  Future<void> updateEntry(
    int generatedID,
    String plainText,
    bool shouldSync,
  ) async {
    var key = await getOrCreateAuthDataKey();
    final encryptedKeyData = await CryptoUtil.encryptChaCha(
      utf8.encode(plainText),
      key,
    );
    String encryptedData = Sodium.bin2base64(encryptedKeyData.encryptedData!);
    String header = Sodium.bin2base64(encryptedKeyData.header!);
    final int affectedRows =
        await _offlineDb.updateEntry(generatedID, encryptedData, header);
    assert(
      affectedRows == 1,
      "updateEntry should have updated exactly one row",
    );
  }

  Future<void> deleteEntry(int genID) async {
    LocalAuthEntity? result = await _offlineDb.getEntryByID(genID);
    if (result == null) {
      _logger.info("No entry found for given id");
      return;
    }
    await _offlineDb.deleteByIDs(generatedIDs: [genID]);
  }

  Future<Uint8List> getOrCreateAuthDataKey() async {
    return _config.getOfflineSecretKey()!;
  }
}
