import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../../../routes/app_routes.dart';

class ImportWalletController extends GetxController {
  // Tab由 DefaultTabController 管理，controller仅追踪索引
  final selectedTab = 0.obs;

  final mnemonicInput = TextEditingController();
  final privateKeyInput = TextEditingController();
  final extendedPublicKeyInput = TextEditingController();

  final mnemonicError = ''.obs;
  final privateKeyError = ''.obs;
  final publicKeyError = ''.obs;

  // Coin selection for private key / extended public key import
  final selectedCoinId = 'btc'.obs;
  final availableCoins = ['btc', 'eth', 'trx', 'bnb'];

  void validateAndImport() {
    switch (selectedTab.value) {
      case 0:
        _importByMnemonic();
        break;
      case 1:
        _importByPrivateKey();
        break;
      case 2:
        _importByExtendedPublicKey();
        break;
    }
  }

  void _importByMnemonic() {
    final input = mnemonicInput.text.trim();
    if (input.isEmpty) {
      mnemonicError.value = '请输入助记词';
      return;
    }

    final words = input.split(RegExp(r'\s+'));
    if (words.length != 12 && words.length != 24) {
      mnemonicError.value = '助记词必须是12或24个词';
      return;
    }

    if (!bip39.validateMnemonic(input)) {
      mnemonicError.value = '无效的助记词';
      return;
    }

    mnemonicError.value = '';
    Get.toNamed(
      AppRoutes.pinSetup,
      arguments: {'mnemonic': input, 'mode': 'import'},
    );
  }

  void _importByPrivateKey() {
    final input = privateKeyInput.text.trim();
    if (input.isEmpty) {
      privateKeyError.value = '请输入私钥';
      return;
    }

    // Basic hex validation
    final hexPattern = RegExp(r'^(0x)?[0-9a-fA-F]{64}$');
    if (!hexPattern.hasMatch(input)) {
      privateKeyError.value = '无效的私钥格式';
      return;
    }

    privateKeyError.value = '';
    Get.toNamed(
      AppRoutes.pinSetup,
      arguments: {
        'privateKey': input,
        'coinId': selectedCoinId.value,
        'mode': 'import_pk',
      },
    );
  }

  void _importByExtendedPublicKey() {
    final input = extendedPublicKeyInput.text.trim();
    if (input.isEmpty) {
      publicKeyError.value = '请输入扩展公钥';
      return;
    }

    // Basic xpub/ypub/zpub validation
    if (!input.startsWith('xpub') &&
        !input.startsWith('ypub') &&
        !input.startsWith('zpub')) {
      publicKeyError.value = '无效的扩展公钥格式';
      return;
    }

    publicKeyError.value = '';
    Get.toNamed(
      AppRoutes.pinSetup,
      arguments: {
        'extendedPublicKey': input,
        'coinId': selectedCoinId.value,
        'mode': 'import_xpub',
      },
    );
  }

  @override
  void onClose() {
    mnemonicInput.dispose();
    privateKeyInput.dispose();
    extendedPublicKeyInput.dispose();
    super.onClose();
  }
}
