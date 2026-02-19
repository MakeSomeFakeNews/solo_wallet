import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/coin_info.dart';

class AddTokenController extends GetxController {
  final RxString selectedChain = 'eth'.obs;
  final contractController = TextEditingController();
  final nameController = TextEditingController();
  final symbolController = TextEditingController();
  final decimalsController = TextEditingController(text: '18');

  final RxBool isLoading = false.obs;
  final RxString contractError = ''.obs;

  final List<Map<String, String>> supportedChains = [
    {'id': 'eth', 'name': 'Ethereum (ERC20)'},
    {'id': 'bnb', 'name': 'BNB Chain (BEP20)'},
    {'id': 'trx', 'name': 'TRON (TRC20)'},
  ];

  CoinType get selectedCoinType {
    switch (selectedChain.value) {
      case 'eth':
        return CoinType.erc20;
      case 'bnb':
        return CoinType.bep20;
      case 'trx':
        return CoinType.trc20;
      default:
        return CoinType.erc20;
    }
  }

  void onChainChanged(String? chainId) {
    if (chainId != null) {
      selectedChain.value = chainId;
      // Reset fields
      contractController.clear();
      nameController.clear();
      symbolController.clear();
      decimalsController.text = chainId == 'trx' ? '6' : '18';
    }
  }

  void onContractChanged(String value) {
    contractError.value = '';
    if (value.isEmpty) return;

    // Basic validation
    if (selectedChain.value == 'trx') {
      if (!value.startsWith('T') || value.length != 34) {
        contractError.value = '无效的TRC20合约地址';
      }
    } else {
      if (!value.startsWith('0x') || value.length != 42) {
        contractError.value = '无效的合约地址';
      }
    }
  }

  Future<void> addToken() async {
    if (contractController.text.isEmpty ||
        nameController.text.isEmpty ||
        symbolController.text.isEmpty) {
      Get.snackbar('提示', '请填写所有必要信息',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    if (contractError.value.isNotEmpty) return;

    isLoading.value = true;
    try {
      // TODO: Save custom token to storage
      await Future.delayed(const Duration(milliseconds: 500));

      Get.back();
      Get.snackbar('成功', '代币已添加',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    contractController.dispose();
    nameController.dispose();
    symbolController.dispose();
    decimalsController.dispose();
    super.onClose();
  }
}
