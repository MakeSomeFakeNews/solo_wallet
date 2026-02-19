import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../values/app_constants.dart';
import 'storage_service.dart';

/// 安全服务 - 管理PIN码验证、生物识别、应用锁等
class SecurityService extends GetxService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  final RxBool isLocked = true.obs;
  final RxInt _failedAttempts = 0.obs;
  final Rx<DateTime?> _lockoutUntil = Rx<DateTime?>(null);

  // ============ PIN码管理 ============

  /// 设置PIN码（存储SHA256哈希）
  Future<bool> setPin(String pin) async {
    if (pin.length != AppConstants.pinLength) return false;
    final hash = _hashPin(pin);
    await StorageService.savePinHash(hash);
    _failedAttempts.value = 0;
    return true;
  }

  /// 验证PIN码
  Future<bool> verifyPin(String pin) async {
    // 检查是否在锁定期
    if (_isLockedOut) return false;

    final storedHash = await StorageService.getPinHash();
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    if (inputHash == storedHash) {
      _failedAttempts.value = 0;
      _lockoutUntil.value = null;
      isLocked.value = false;
      return true;
    }

    // 记录失败次数
    _failedAttempts.value++;
    if (_failedAttempts.value >= AppConstants.maxPinAttempts) {
      _lockoutUntil.value = DateTime.now().add(
        const Duration(seconds: AppConstants.pinLockDurationSeconds),
      );
    }
    return false;
  }

  // Note: call checkPinSet() instead for async check
  Future<bool> checkPinSet() async {
    final hash = await StorageService.getPinHash();
    return hash != null;
  }

  bool get _isLockedOut {
    final lockout = _lockoutUntil.value;
    if (lockout == null) return false;
    if (DateTime.now().isAfter(lockout)) {
      _lockoutUntil.value = null;
      _failedAttempts.value = 0;
      return false;
    }
    return true;
  }

  int get failedAttempts => _failedAttempts.value;

  DateTime? get lockoutUntil => _lockoutUntil.value;

  int get remainingAttempts =>
      AppConstants.maxPinAttempts - _failedAttempts.value;

  String _hashPin(String pin) {
    final bytes = utf8.encode('${pin}solo_wallet_salt_v1');
    return sha256.convert(bytes).toString();
  }

  // ============ 生物识别 ============

  /// 检查设备是否支持生物识别
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// 执行生物识别验证
  Future<bool> authenticateWithBiometrics() async {
    if (!StorageService.biometricEnabled) return false;
    try {
      final result = await _localAuth.authenticate(
        localizedReason: '请验证生物识别以解锁钱包',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (result) isLocked.value = false;
      return result;
    } on PlatformException {
      return false;
    }
  }

  // ============ 应用锁 ============

  void lock() {
    isLocked.value = true;
  }

  void unlock() {
    isLocked.value = false;
  }

  // ============ 防截屏 ============

  Future<void> setScreenProtection(bool enabled) async {
    await StorageService.setAntiScreenshot(enabled);
    if (enabled) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
  }
}
