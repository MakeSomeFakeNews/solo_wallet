import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/wallet_service.dart';
import '../../core/services/security_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/values/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class SettingsController extends GetxController {
  final WalletService walletService = Get.find();
  final SecurityService securityService = Get.find();

  final RxString themeMode = 'system'.obs;
  final RxString fiatCurrency = 'CNY'.obs;
  final RxBool biometricEnabled = false.obs;
  final RxBool isBiometricAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkBiometric();
    fiatCurrency.value = StorageService.fiatCurrency;
    biometricEnabled.value = StorageService.biometricEnabled;
    themeMode.value = StorageService.read<String>('theme_mode') ?? 'system';
  }

  Future<void> _checkBiometric() async {
    isBiometricAvailable.value = await securityService.isBiometricAvailable();
  }

  Future<void> toggleBiometric(bool value) async {
    if (value && !isBiometricAvailable.value) {
      Get.snackbar(AppStrings.error, '设备不支持生物识别');
      return;
    }
    await StorageService.setBiometricEnabled(value);
    biometricEnabled.value = value;
  }

  Future<void> changeFiatCurrency(String currency) async {
    await StorageService.setFiatCurrency(currency);
    fiatCurrency.value = currency;
  }

  Future<void> changeTheme(String mode) async {
    await StorageService.write('theme_mode', mode);
    themeMode.value = mode;
    switch (mode) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  void navigateToChangePin() {
    Get.toNamed(AppRoutes.pinSetup, arguments: {'mode': 'change'});
  }

  void navigateToWalletDetail() {
    Get.toNamed(AppRoutes.walletDetail);
  }

  void navigateToNodeSettings() {
    Get.toNamed(AppRoutes.nodeSettings);
  }

  void navigateToSecurity() {
    Get.toNamed(AppRoutes.security);
  }

  Map<String, String> exportAllPublicKeys() {
    final wallet = walletService.currentWallet.value;
    if (wallet == null) return {};
    final Map<String, String> keys = {};
    for (final account in wallet.accounts) {
      if (account.extendedPublicKey != null) {
        keys[account.coinId] = account.extendedPublicKey!;
      }
    }
    return keys;
  }

  Future<void> confirmDeleteWallet() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text(AppStrings.warning),
        content: const Text('删除钱包将清除所有本地数据，包括私钥和助记词。此操作不可恢复。\n\n请确认您已备份助记词。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await walletService.deleteWallet();
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
