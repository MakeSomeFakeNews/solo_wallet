import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/crypto/coins/coin_registry.dart';
import '../../core/models/coin_info.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/app_strings.dart';
import '../../core/services/wallet_service.dart';
import '../../routes/app_routes.dart';

class SendController extends GetxController {
  final WalletService walletService = Get.find();

  late final String coinId;
  late final CoinInfo coinInfo;

  final addressController = TextEditingController();
  final amountController = TextEditingController();

  final RxBool showAdvancedOptions = false.obs;
  final RxBool isValidAddress = false.obs;
  final RxString addressError = ''.obs;

  // ETH advanced options
  final RxDouble gasPrice = AppConstants.defaultGasPriceGwei.obs;
  final RxInt gasLimit = AppConstants.defaultEthGasLimit.obs;
  final RxInt nonce = 0.obs;

  // BTC advanced options
  final RxInt feeRate = AppConstants.defaultBtcFeeRate.obs;

  // Available balance (mock)
  final RxString availableBalance = '0'.obs;

  // Signed transaction result
  final RxString signedTxHex = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    coinId = args?['coinId'] ?? 'btc';

    coinInfo = CoinRegistry.getById(coinId) ?? CoinRegistry.getAll().first;

    // Set gas limit for tokens
    if (coinInfo.isToken) {
      gasLimit.value = AppConstants.defaultErc20GasLimit;
    }

    _loadAvailableBalance();
  }

  void _loadAvailableBalance() {
    // Mock balances
    switch (coinId) {
      case 'btc':
        availableBalance.value = '0.12345678';
        break;
      case 'eth':
        availableBalance.value = '1.5';
        break;
      case 'trx':
        availableBalance.value = '10000';
        break;
      case 'bnb':
        availableBalance.value = '0.5';
        break;
      default:
        availableBalance.value = '0';
    }
  }

  void onAddressChanged(String value) {
    addressError.value = '';
    if (value.isEmpty) {
      isValidAddress.value = false;
      return;
    }

    // Basic address validation
    switch (coinId) {
      case 'btc':
        isValidAddress.value = value.startsWith('1') ||
            value.startsWith('3') ||
            value.startsWith('bc1');
        if (!isValidAddress.value) {
          addressError.value = AppStrings.invalidAddress;
        }
        break;
      case 'eth':
      case 'bnb':
      case 'usdt_erc20':
      case 'usdt_bep20':
        isValidAddress.value =
            value.startsWith('0x') && value.length == 42;
        if (!isValidAddress.value) {
          addressError.value = AppStrings.invalidAddress;
        }
        break;
      case 'trx':
      case 'usdt_trc20':
        isValidAddress.value =
            value.startsWith('T') && value.length == 34;
        if (!isValidAddress.value) {
          addressError.value = AppStrings.invalidAddress;
        }
        break;
      default:
        isValidAddress.value = value.isNotEmpty;
    }
  }

  Future<void> scanQrCode() async {
    final result = await Get.toNamed('/qr-scanner');
    if (result != null && result is String) {
      addressController.text = result;
      onAddressChanged(result);
    }
  }

  void setMaxAmount() {
    amountController.text = availableBalance.value;
  }

  String get estimatedFee {
    if (coinId == 'btc') {
      return '${feeRate.value} sat/byte';
    } else if (coinId == 'eth' ||
        coinId == 'bnb' ||
        coinInfo.coinType == CoinType.erc20 ||
        coinInfo.coinType == CoinType.bep20) {
      final feeGwei = gasPrice.value * gasLimit.value;
      final feeEth = feeGwei / 1e9;
      return '${feeEth.toStringAsFixed(6)} ${coinId == 'bnb' ? 'BNB' : 'ETH'}';
    } else if (coinId == 'trx' || coinInfo.coinType == CoinType.trc20) {
      return '~1 TRX';
    }
    return '--';
  }

  void proceedToConfirm() {
    if (!isValidAddress.value) {
      Get.snackbar('错误', AppStrings.invalidAddress,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (amountController.text.isEmpty) {
      Get.snackbar('错误', '请输入金额', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.toNamed(AppRoutes.sendConfirm, arguments: {
      'coinId': coinId,
      'toAddress': addressController.text,
      'amount': amountController.text,
      'fee': estimatedFee,
    });
  }

  Future<void> signTransaction() async {
    // TODO: Implement actual offline signing
    await Future.delayed(const Duration(seconds: 1));

    // Mock signed transaction
    signedTxHex.value =
        'f86c808504a817c80082520894742d35cc6634c0532925a3b844bc9e7595f2bd1887'
        '0de0b6b3a764000080269f22d7f1d8a9a0d3e6f5ab5eae38e1c5d3d2c4b4a87564'
        '83b3c9d7f0e2a1b8c4f6d5e7a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9';

    Get.toNamed(AppRoutes.signedTx, arguments: {
      'signedTx': signedTxHex.value,
      'coinId': coinId,
    });
  }

  @override
  void onClose() {
    addressController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
