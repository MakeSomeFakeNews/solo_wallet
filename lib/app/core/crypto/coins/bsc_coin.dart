import '../../models/coin_info.dart';
import '../../values/app_constants.dart';
import 'eth_coin.dart';

/// BNB Smart Chain (BSC) 币种实现
/// 完全复用 ETH 实现，仅修改 chainId 和币种信息
class BscCoin extends EthCoin {
  @override
  CoinInfo get info => const CoinInfo(
        id: AppConstants.coinBnb,
        symbol: 'BNB',
        name: 'BNB Smart Chain',
        bip44CoinType: AppConstants.bscCoinType, // 60, same as ETH
        decimals: 18,
        coinType: CoinType.native,
        iconPath: 'assets/coins/bnb.png',
        colorHex: '#F3BA2F',
      );

  @override
  int get chainId => AppConstants.bscChainId; // 56
}
