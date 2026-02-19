import 'package:get/get.dart';

import '../../core/crypto/coins/coin_registry.dart';
import '../../core/models/coin_info.dart';
import '../../core/services/wallet_service.dart';

/// 单个币种余额条目
class CoinBalanceItem {
  final CoinInfo coinInfo;
  final BigInt balance;
  final double? usdValue;

  CoinBalanceItem({
    required this.coinInfo,
    required this.balance,
    this.usdValue,
  });

  String get formattedBalance => coinInfo.formatAmount(balance);

  String get formattedUsdValue {
    if (usdValue == null) return '--';
    return '\$${usdValue!.toStringAsFixed(2)}';
  }
}

class HomeController extends GetxController {
  final WalletService walletService = Get.find();

  final RxInt selectedCoinIndex = (-1).obs;
  final RxBool hideBalance = false.obs;
  final RxList<CoinBalanceItem> coinItems = <CoinBalanceItem>[].obs;
  final RxDouble totalBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshBalances();
  }

  void toggleHideBalance() {
    hideBalance.value = !hideBalance.value;
  }

  void selectCoin(int index) {
    if (selectedCoinIndex.value == index) {
      selectedCoinIndex.value = -1;
    } else {
      selectedCoinIndex.value = index;
    }
  }

  CoinBalanceItem? get selectedCoin {
    final idx = selectedCoinIndex.value;
    if (idx < 0 || idx >= coinItems.length) return null;
    return coinItems[idx];
  }

  void refreshBalances() {
    final wallet = walletService.currentWallet.value;
    if (wallet == null) return;

    final items = <CoinBalanceItem>[];
    double total = 0.0;

    for (final coinId in wallet.activeCoins) {
      final coinInfo = CoinRegistry.getById(coinId);
      if (coinInfo == null) continue;

      // Mock balances for now
      final BigInt mockBalance;
      final double mockUsdValue;
      switch (coinId) {
        case 'btc':
          mockBalance = BigInt.from(12345678); // 0.12345678 BTC
          mockUsdValue = 5234.56;
          break;
        case 'eth':
          mockBalance = BigInt.parse('1500000000000000000'); // 1.5 ETH
          mockUsdValue = 3750.00;
          break;
        case 'trx':
          mockBalance = BigInt.from(10000000000); // 10000 TRX
          mockUsdValue = 850.00;
          break;
        case 'bnb':
          mockBalance = BigInt.parse('500000000000000000'); // 0.5 BNB
          mockUsdValue = 150.00;
          break;
        default:
          mockBalance = BigInt.zero;
          mockUsdValue = 0.0;
      }

      items.add(CoinBalanceItem(
        coinInfo: coinInfo,
        balance: mockBalance,
        usdValue: mockUsdValue,
      ));
      total += mockUsdValue;
    }

    coinItems.value = items;
    totalBalance.value = total;
  }
}
