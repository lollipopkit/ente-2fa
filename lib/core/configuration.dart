import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:ente_auth/models/key_attributes.dart';
import 'package:ente_auth/models/key_gen_result.dart';
import 'package:ente_auth/models/private_key_attributes.dart';
import 'package:ente_auth/utils/crypto_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuration {
  Configuration._privateConstructor();

  static final Configuration instance = Configuration._privateConstructor();

  static const emailKey = "email";
  static const keyAttributesKey = "key_attributes";
  static const keyShouldShowLockScreen = "should_show_lock_screen";
  static const lastTempFolderClearTimeKey = "last_temp_folder_clear_time";
  static const offlineAuthSecretKey = "offline_auth_secret_key";
  static const tokenKey = "token";
  static const encryptedTokenKey = "encrypted_token";
  static const userIDKey = "user_id";
  static const hasMigratedSecureStorageKey = "has_migrated_secure_storage";
  static const hasOptedForOfflineModeKey = "has_opted_for_offline_mode";

  final kTempFolderDeletionTimeBuffer = const Duration(days: 1).inMicroseconds;

  static final _logger = Logger("Configuration");

  late String _documentsDirectory;
  late SharedPreferences _preferences;
  String? _offlineAuthKey;
  late FlutterSecureStorage _secureStorage;
  late String _tempDirectory;

  String? _volatilePassword;

  final _secureStorageOptionsIOS = const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
    _documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    _tempDirectory = _documentsDirectory + "/temp/";
    final tempDirectory = io.Directory(_tempDirectory);
    try {
      final currentTime = DateTime.now().microsecondsSinceEpoch;
      if (tempDirectory.existsSync() &&
          (_preferences.getInt(lastTempFolderClearTimeKey) ?? 0) <
              (currentTime - kTempFolderDeletionTimeBuffer)) {
        await tempDirectory.delete(recursive: true);
        await _preferences.setInt(lastTempFolderClearTimeKey, currentTime);
        _logger.info("Cleared temp folder");
      } else {
        _logger.info("Skipping temp folder clear");
      }
    } catch (e) {
      _logger.warning(e);
    }
    tempDirectory.createSync(recursive: true);
    await _initOfflineAccount();
  }

  Future<void> _initOfflineAccount() async {
    _offlineAuthKey = await _secureStorage.read(
      key: offlineAuthSecretKey,
      iOptions: _secureStorageOptionsIOS,
    );
  }

  Future<KeyGenResult> generateKey(String password) async {
    // Create a master key
    final masterKey = CryptoUtil.generateKey();

    // Create a recovery key
    final recoveryKey = CryptoUtil.generateKey();

    // Encrypt master key and recovery key with each other
    final encryptedMasterKey = CryptoUtil.encryptSync(masterKey, recoveryKey);
    final encryptedRecoveryKey = CryptoUtil.encryptSync(recoveryKey, masterKey);

    // Derive a key from the password that will be used to encrypt and
    // decrypt the master key
    final kekSalt = CryptoUtil.getSaltToDeriveKey();
    final derivedKeyResult = await CryptoUtil.deriveSensitiveKey(
      utf8.encode(password),
      kekSalt,
    );
    final loginKey = await CryptoUtil.deriveLoginKey(derivedKeyResult.key);

    // Encrypt the key with this derived key
    final encryptedKeyData =
        CryptoUtil.encryptSync(masterKey, derivedKeyResult.key);

    // Generate a public-private keypair and encrypt the latter
    final keyPair = await CryptoUtil.generateKeyPair();
    final encryptedSecretKeyData =
        CryptoUtil.encryptSync(keyPair.sk, masterKey);

    final attributes = KeyAttributes(
      Sodium.bin2base64(kekSalt),
      Sodium.bin2base64(encryptedKeyData.encryptedData!),
      Sodium.bin2base64(encryptedKeyData.nonce!),
      Sodium.bin2base64(keyPair.pk),
      Sodium.bin2base64(encryptedSecretKeyData.encryptedData!),
      Sodium.bin2base64(encryptedSecretKeyData.nonce!),
      derivedKeyResult.memLimit,
      derivedKeyResult.opsLimit,
      Sodium.bin2base64(encryptedMasterKey.encryptedData!),
      Sodium.bin2base64(encryptedMasterKey.nonce!),
      Sodium.bin2base64(encryptedRecoveryKey.encryptedData!),
      Sodium.bin2base64(encryptedRecoveryKey.nonce!),
    );
    final privateAttributes = PrivateKeyAttributes(
      Sodium.bin2base64(masterKey),
      Sodium.bin2hex(recoveryKey),
      Sodium.bin2base64(keyPair.sk),
    );
    return KeyGenResult(attributes, privateAttributes, loginKey);
  }

  Future<void> setEncryptedToken(String encryptedToken) async {
    await _preferences.setString(encryptedTokenKey, encryptedToken);
  }

  String? getEncryptedToken() {
    return _preferences.getString(encryptedTokenKey);
  }

  String? getEmail() {
    return _preferences.getString(emailKey);
  }

  Future<void> setEmail(String email) async {
    await _preferences.setString(emailKey, email);
  }

  int? getUserID() {
    return _preferences.getInt(userIDKey);
  }

  Future<void> setUserID(int userID) async {
    await _preferences.setInt(userIDKey, userID);
  }

  Future<void> setKeyAttributes(KeyAttributes attributes) async {
    await _preferences.setString(keyAttributesKey, attributes.toJson());
  }

  KeyAttributes? getKeyAttributes() {
    final jsonValue = _preferences.getString(keyAttributesKey);
    if (jsonValue == null) {
      return null;
    } else {
      return KeyAttributes.fromJson(jsonValue);
    }
  }

  Uint8List? getOfflineSecretKey() {
    return _offlineAuthKey == null ? null : Sodium.base642bin(_offlineAuthKey!);
  }

  // Caution: This directory is cleared on app start
  String getTempDirectory() {
    return _tempDirectory;
  }

  bool hasOptedForOfflineMode() {
    return _preferences.getBool(hasOptedForOfflineModeKey) ?? false;
  }

  Future<void> optForOfflineMode() async {
    if ((await _secureStorage.containsKey(
      key: offlineAuthSecretKey,
      iOptions: _secureStorageOptionsIOS,
    ))) {
      _offlineAuthKey = await _secureStorage.read(
        key: offlineAuthSecretKey,
        iOptions: _secureStorageOptionsIOS,
      );
    } else {
      _offlineAuthKey = Sodium.bin2base64(CryptoUtil.generateKey());
      await _secureStorage.write(
        key: offlineAuthSecretKey,
        value: _offlineAuthKey,
        iOptions: _secureStorageOptionsIOS,
      );
    }
    await _preferences.setBool(hasOptedForOfflineModeKey, true);
  }

  bool shouldShowLockScreen() {
    if (_preferences.containsKey(keyShouldShowLockScreen)) {
      return _preferences.getBool(keyShouldShowLockScreen)!;
    } else {
      return false;
    }
  }

  Future<void> setShouldShowLockScreen(bool value) {
    return _preferences.setBool(keyShouldShowLockScreen, value);
  }

  void setVolatilePassword(String? volatilePassword) {
    _volatilePassword = volatilePassword;
  }

  String? getVolatilePassword() {
    return _volatilePassword;
  }
}
