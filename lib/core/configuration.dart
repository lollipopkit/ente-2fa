import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

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

    if (!hasOptedForOfflineMode()) {
      await Configuration.instance.optForOfflineMode();
    }
  }

  Future<void> _initOfflineAccount() async {
    _offlineAuthKey = await _secureStorage.read(
      key: offlineAuthSecretKey,
      iOptions: _secureStorageOptionsIOS,
    );
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
}
