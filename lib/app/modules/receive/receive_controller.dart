import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/crypto/coins/coin_registry.dart';
import '../../core/models/coin_info.dart';
import '../../core/services/wallet_service.dart';

class ReceiveController extends GetxController {
  final WalletService walletService = Get.find();

  late final String coinId;
  late final CoinInfo coinInfo;

  final Rx<String> currentAddress = ''.obs;
  final Rx<AddressType> currentAddressType = AddressType.standard.obs;
  final RxList<AddressType> supportedTypes = <AddressType>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    coinId = args?['coinId'] ?? 'btc';

    coinInfo = CoinRegistry.getById(coinId) ??
        CoinRegistry.getAll().first;

    supportedTypes.value = coinInfo.supportedAddressTypes;
    if (supportedTypes.isNotEmpty) {
      currentAddressType.value = supportedTypes.first;
    }

    _loadAddress();
  }

  void _loadAddress() {
    final address = walletService.getAddress(coinId);
    if (address != null && address.isNotEmpty) {
      currentAddress.value = address;
    } else {
      // Mock address for display
      switch (coinId) {
        case 'btc':
          currentAddress.value =
              'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
          break;
        case 'eth':
        case 'bnb':
          currentAddress.value =
              '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18';
          break;
        case 'trx':
          currentAddress.value = 'TJRabPrwbZy45sbavfcjinPJC18kjpRTv8';
          break;
        default:
          currentAddress.value =
              '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18';
      }
    }
  }

  void copyAddress() {
    Clipboard.setData(ClipboardData(text: currentAddress.value));
    Get.snackbar(
      '已复制',
      '地址已复制到剪贴板',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void generateNewAddress() {
    // TODO: Generate new HD address from wallet service
    Get.snackbar(
      '提示',
      '新地址生成功能开发中',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void selectAddressType(AddressType type) {
    currentAddressType.value = type;
    _loadAddress();
  }

  String get addressTypeLabel {
    switch (currentAddressType.value) {
      case AddressType.legacy:
        return 'Legacy (P2PKH)';
      case AddressType.segwit:
        return 'SegWit (P2SH)';
      case AddressType.nativeSegwit:
        return 'Native SegWit (Bech32)';
      case AddressType.standard:
        return '标准地址';
    }
  }
}
