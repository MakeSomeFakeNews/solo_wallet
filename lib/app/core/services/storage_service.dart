import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import '../values/app_constants.dart';

/// 统一存储服务
/// - flutter_secure_storage: 存储助记词、私钥等敏感数据（加密）
/// - GetStorage: 存储非敏感配置数据
class StorageService {
  static late FlutterSecureStorage _secureStorage;
  static late GetStorage _box;

  static Future<void> init() async {
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'solo_wallet_secure',
    );
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'solo_wallet',
    );
    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
    _box = GetStorage('solo_wallet');
    await _box.initStorage;
  }

  // ============ 安全存储（敏感数据） ============

  /// 存储助记词（加密）
  static Future<void> saveMnemonic(String mnemonic) async {
    await _secureStorage.write(
      key: AppConstants.secureKeyMnemonic,
      value: mnemonic,
    );
  }

  /// 读取助记词
  static Future<String?> getMnemonic() async {
    return _secureStorage.read(key: AppConstants.secureKeyMnemonic);
  }

  /// 存储私钥（按币种ID分开存储）
  static Future<void> savePrivateKey(String coinId, String privateKeyHex) async {
    await _secureStorage.write(
      key: '${AppConstants.secureKeyPrivateKeyPrefix}$coinId',
      value: privateKeyHex,
    );
  }

  /// 读取私钥
  static Future<String?> getPrivateKey(String coinId) async {
    return _secureStorage.read(
      key: '${AppConstants.secureKeyPrivateKeyPrefix}$coinId',
    );
  }

  /// 存储主种子（hex）
  static Future<void> saveMasterSeed(String seedHex) async {
    await _secureStorage.write(
      key: AppConstants.secureKeyMasterSeed,
      value: seedHex,
    );
  }

  /// 读取主种子
  static Future<String?> getMasterSeed() async {
    return _secureStorage.read(key: AppConstants.secureKeyMasterSeed);
  }

  /// 存储PIN哈希
  static Future<void> savePinHash(String pinHash) async {
    await _secureStorage.write(key: AppConstants.keyPinHash, value: pinHash);
  }

  /// 读取PIN哈希
  static Future<String?> getPinHash() async {
    return _secureStorage.read(key: AppConstants.keyPinHash);
  }

  /// 清除所有安全存储数据
  static Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // ============ 普通存储（非敏感配置） ============

  static T? read<T>(String key) => _box.read<T>(key);

  static Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  static Future<void> remove(String key) async {
    await _box.remove(key);
  }

  static bool hasData(String key) => _box.hasData(key);

  // ============ 钱包数据 ============

  static Future<void> saveWalletData(Map<String, dynamic> walletJson) async {
    await _box.write(AppConstants.keyWalletData, jsonEncode(walletJson));
  }

  static Map<String, dynamic>? getWalletData() {
    final data = _box.read<String>(AppConstants.keyWalletData);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static bool get hasWallet => _box.hasData(AppConstants.keyWalletData);

  // ============ 交易记录 ============

  static Future<void> saveTransactions(
    String coinId,
    List<Map<String, dynamic>> txList,
  ) async {
    await _box.write(
      '${AppConstants.keyTransactions}$coinId',
      jsonEncode(txList),
    );
  }

  static List<Map<String, dynamic>> getTransactions(String coinId) {
    final data = _box.read<String>('${AppConstants.keyTransactions}$coinId');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // ============ 应用设置 ============

  static bool get biometricEnabled =>
      _box.read<bool>(AppConstants.keyBiometricEnabled) ?? false;

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _box.write(AppConstants.keyBiometricEnabled, enabled);
  }

  static bool get antiScreenshot =>
      _box.read<bool>(AppConstants.keyAntiScreenshot) ?? true;

  static Future<void> setAntiScreenshot(bool enabled) async {
    await _box.write(AppConstants.keyAntiScreenshot, enabled);
  }

  static bool get clipboardMonitor =>
      _box.read<bool>(AppConstants.keyClipboardMonitor) ?? true;

  static Future<void> setClipboardMonitor(bool enabled) async {
    await _box.write(AppConstants.keyClipboardMonitor, enabled);
  }

  static String get fiatCurrency =>
      _box.read<String>(AppConstants.keyFiatCurrency) ?? 'CNY';

  static Future<void> setFiatCurrency(String currency) async {
    await _box.write(AppConstants.keyFiatCurrency, currency);
  }

  static bool get hideZeroBalance =>
      _box.read<bool>(AppConstants.keyHideZeroBalance) ?? false;

  static Future<void> setHideZeroBalance(bool hide) async {
    await _box.write(AppConstants.keyHideZeroBalance, hide);
  }

  static bool get onboardingComplete =>
      _box.read<bool>(AppConstants.keyOnboardingComplete) ?? false;

  static Future<void> setOnboardingComplete(bool complete) async {
    await _box.write(AppConstants.keyOnboardingComplete, complete);
  }

  static List<String> get activeCoins {
    final data = _box.read<String>(AppConstants.keyActiveCoins);
    if (data == null) return [];
    return List<String>.from(jsonDecode(data) as List);
  }

  static Future<void> setActiveCoins(List<String> coins) async {
    await _box.write(AppConstants.keyActiveCoins, jsonEncode(coins));
  }

  static Map<String, String> get networkNodes {
    final data = _box.read<String>(AppConstants.keyNetworkNodes);
    if (data == null) return {};
    return Map<String, String>.from(jsonDecode(data) as Map);
  }

  static Future<void> setNetworkNodes(Map<String, String> nodes) async {
    await _box.write(AppConstants.keyNetworkNodes, jsonEncode(nodes));
  }

  // ============ 全部清除（重置钱包） ============

  static Future<void> clearAll() async {
    await clearSecureStorage();
    await _box.erase();
  }
}
