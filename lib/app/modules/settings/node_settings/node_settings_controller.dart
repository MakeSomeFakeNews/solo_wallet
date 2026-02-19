import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/values/app_strings.dart';

class NodeSettingsController extends GetxController {
  final Map<String, TextEditingController> nodeControllers = {};
  final RxBool isSaving = false.obs;

  static const Map<String, String> defaultNodes = {
    'eth': 'https://mainnet.infura.io/v3/YOUR_KEY',
    'bsc': 'https://bsc-dataseed.binance.org/',
    'trx': 'https://api.trongrid.io',
  };

  static const Map<String, String> chainNames = {
    'eth': 'Ethereum (ETH)',
    'bsc': 'BSC (BNB Chain)',
    'trx': 'TRON (TRX)',
  };

  @override
  void onInit() {
    super.onInit();
    for (final chainId in defaultNodes.keys) {
      nodeControllers[chainId] = TextEditingController();
    }
    loadNodes();
  }

  @override
  void onClose() {
    for (final c in nodeControllers.values) {
      c.dispose();
    }
    super.onClose();
  }

  void loadNodes() {
    final saved = StorageService.networkNodes;
    for (final entry in defaultNodes.entries) {
      nodeControllers[entry.key]?.text =
          saved[entry.key] ?? entry.value;
    }
  }

  Future<void> saveNodes() async {
    isSaving.value = true;
    final Map<String, String> nodes = {};
    for (final entry in nodeControllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        nodes[entry.key] = text;
      }
    }
    await StorageService.setNetworkNodes(nodes);
    isSaving.value = false;
    Get.snackbar(AppStrings.success, '节点配置已保存');
  }

  void resetToDefault(String chainId) {
    final defaultUrl = defaultNodes[chainId];
    if (defaultUrl != null) {
      nodeControllers[chainId]?.text = defaultUrl;
    }
  }

  void resetAllToDefault() {
    for (final entry in defaultNodes.entries) {
      nodeControllers[entry.key]?.text = entry.value;
    }
  }
}
