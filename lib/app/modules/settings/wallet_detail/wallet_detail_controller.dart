import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/values/app_strings.dart';

class WalletDetailController extends GetxController {
  final WalletService walletService = Get.find();

  String get walletName => walletService.currentWallet.value?.name ?? '-';

  String get walletType {
    final type = walletService.currentWallet.value?.type;
    switch (type) {
      case WalletType.hd:
        return 'HD钱包 (BIP44)';
      case WalletType.privateKey:
        return '私钥导入';
      case WalletType.watchOnly:
        return '观察钱包';
      default:
        return '-';
    }
  }

  List<Map<String, String>> get coinDetails {
    final wallet = walletService.currentWallet.value;
    if (wallet == null) return [];
    return wallet.accounts
        .where((a) => wallet.activeCoins.contains(a.coinId))
        .map((a) => {
              'coinId': a.coinId,
              'symbol': _coinSymbol(a.coinId),
              'path': a.derivationPath,
              'xpub': a.extendedPublicKey ?? '-',
              'address': a.address,
            })
        .toList();
  }

  String _coinSymbol(String coinId) {
    switch (coinId) {
      case AppConstants.coinBtc:
        return 'BTC';
      case AppConstants.coinEth:
        return 'ETH';
      case AppConstants.coinTrx:
        return 'TRX';
      case AppConstants.coinBnb:
        return 'BNB';
      case AppConstants.coinUsdtErc20:
        return 'USDT (ERC20)';
      case AppConstants.coinUsdtTrc20:
        return 'USDT (TRC20)';
      case AppConstants.coinUsdtBep20:
        return 'USDT (BEP20)';
      default:
        return coinId.toUpperCase();
    }
  }

  void copyXpub(String coinId) {
    final wallet = walletService.currentWallet.value;
    if (wallet == null) return;
    final account = wallet.getAccount(coinId);
    if (account?.extendedPublicKey != null) {
      Clipboard.setData(ClipboardData(text: account!.extendedPublicKey!));
      Get.snackbar(AppStrings.success, '扩展公钥已复制');
    }
  }

  void copyAddress(String coinId) {
    final wallet = walletService.currentWallet.value;
    if (wallet == null) return;
    final address = wallet.getAddress(coinId);
    if (address != null) {
      Clipboard.setData(ClipboardData(text: address));
      Get.snackbar(AppStrings.success, AppStrings.addressCopied);
    }
  }
}
