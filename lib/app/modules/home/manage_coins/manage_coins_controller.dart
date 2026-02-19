import 'package:get/get.dart';

import '../../../core/crypto/coins/coin_registry.dart';
import '../../../core/models/coin_info.dart';
import '../../../core/services/wallet_service.dart';

class ManageCoinsController extends GetxController {
  final WalletService walletService = Get.find();

  final RxList<CoinInfo> allCoins = <CoinInfo>[].obs;
  final RxList<CoinInfo> filteredCoins = <CoinInfo>[].obs;
  // 使用 RxList 替代 RxSet 避免 protected member 问题
  final RxList<String> activeCoinIds = <String>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
  }

  void _loadCoins() {
    allCoins.value = CoinRegistry.getAll();
    filteredCoins.value = allCoins;

    final wallet = walletService.currentWallet.value;
    if (wallet != null) {
      activeCoinIds.value = List<String>.from(wallet.activeCoins);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCoins.value = allCoins;
    } else {
      final lowerQuery = query.toLowerCase();
      filteredCoins.value = allCoins
          .where((c) =>
              c.name.toLowerCase().contains(lowerQuery) ||
              c.symbol.toLowerCase().contains(lowerQuery))
          .toList();
    }
  }

  bool isCoinActive(String coinId) => activeCoinIds.contains(coinId);

  void toggleCoin(String coinId) {
    if (activeCoinIds.contains(coinId)) {
      activeCoinIds.removeWhere((id) => id == coinId);
    } else {
      activeCoinIds.add(coinId);
    }
  }

  Future<void> saveChanges() async {
    final wallet = walletService.currentWallet.value;
    if (wallet == null) return;

    // Deactivate removed coins
    for (final coinId in wallet.activeCoins) {
      if (!activeCoinIds.contains(coinId)) {
        await walletService.deactivateCoin(coinId);
      }
    }

    // Activate new coins
    for (final coinId in activeCoinIds) {
      if (!wallet.activeCoins.contains(coinId)) {
        await walletService.activateCoin(coinId);
      }
    }

    Get.back();
  }
}
