import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/values/app_strings.dart';

class ExportKeyController extends GetxController {
  final WalletService walletService = Get.find();

  String? coinId;
  final RxString privateKey = ''.obs;
  final RxBool isKeyVisible = false.obs;
  final RxBool isLoading = true.obs;

  List<String> get availableCoins {
    final wallet = walletService.currentWallet.value;
    if (wallet == null) return [];
    return wallet.activeCoins;
  }

  @override
  void onInit() {
    super.onInit();
    coinId = Get.arguments?['coinId'] as String?;
    if (coinId == null && availableCoins.isNotEmpty) {
      coinId = availableCoins.first;
    }
    _loadPrivateKey();
  }

  Future<void> _loadPrivateKey() async {
    isLoading.value = true;
    if (coinId != null) {
      privateKey.value = await StorageService.getPrivateKey(coinId!) ?? '';
    }
    isLoading.value = false;
  }

  Future<void> selectCoin(String newCoinId) async {
    coinId = newCoinId;
    isKeyVisible.value = false;
    await _loadPrivateKey();
  }

  void toggleVisibility() {
    isKeyVisible.value = !isKeyVisible.value;
  }

  void copyKey() {
    if (privateKey.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: privateKey.value));
    Get.snackbar(
      AppStrings.warning,
      '私钥已复制到剪贴板，请注意安全！',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
