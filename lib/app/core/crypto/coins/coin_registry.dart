import 'dart:ui';

import '../../models/coin_info.dart';
import '../../values/app_constants.dart';

/// 币种注册表 - 管理所有支持的币种信息
class CoinRegistry {
  static final List<CoinInfo> _coins = [
    const CoinInfo(
      id: AppConstants.coinBtc,
      symbol: 'BTC',
      name: 'Bitcoin',
      bip44CoinType: AppConstants.btcCoinType,
      decimals: 8,
      coinType: CoinType.native,
      iconPath: 'assets/coins/btc.png',
      colorHex: '#F7931A',
      supportedAddressTypes: [
        AddressType.legacy,
        AddressType.segwit,
        AddressType.nativeSegwit,
      ],
    ),
    const CoinInfo(
      id: AppConstants.coinEth,
      symbol: 'ETH',
      name: 'Ethereum',
      bip44CoinType: AppConstants.ethCoinType,
      decimals: 18,
      coinType: CoinType.native,
      iconPath: 'assets/coins/eth.png',
      colorHex: '#627EEA',
      supportedAddressTypes: [AddressType.standard],
    ),
    const CoinInfo(
      id: AppConstants.coinTrx,
      symbol: 'TRX',
      name: 'TRON',
      bip44CoinType: AppConstants.trxCoinType,
      decimals: 6,
      coinType: CoinType.native,
      iconPath: 'assets/coins/trx.png',
      colorHex: '#E50914',
      supportedAddressTypes: [AddressType.standard],
    ),
    const CoinInfo(
      id: AppConstants.coinBnb,
      symbol: 'BNB',
      name: 'BNB Chain',
      bip44CoinType: AppConstants.bscCoinType,
      decimals: 18,
      coinType: CoinType.native,
      iconPath: 'assets/coins/bnb.png',
      colorHex: '#F3BA2F',
      supportedAddressTypes: [AddressType.standard],
    ),
    const CoinInfo(
      id: AppConstants.coinUsdtErc20,
      symbol: 'USDT',
      name: 'Tether (ERC20)',
      bip44CoinType: AppConstants.ethCoinType,
      decimals: 6,
      coinType: CoinType.erc20,
      contractAddress: AppConstants.usdtErc20Contract,
      parentCoinId: AppConstants.coinEth,
      iconPath: 'assets/coins/usdt.png',
      colorHex: '#26A17B',
      supportedAddressTypes: [AddressType.standard],
    ),
    const CoinInfo(
      id: AppConstants.coinUsdtTrc20,
      symbol: 'USDT',
      name: 'Tether (TRC20)',
      bip44CoinType: AppConstants.trxCoinType,
      decimals: 6,
      coinType: CoinType.trc20,
      contractAddress: AppConstants.usdtTrc20Contract,
      parentCoinId: AppConstants.coinTrx,
      iconPath: 'assets/coins/usdt.png',
      colorHex: '#26A17B',
      supportedAddressTypes: [AddressType.standard],
    ),
    const CoinInfo(
      id: AppConstants.coinUsdtBep20,
      symbol: 'USDT',
      name: 'Tether (BEP20)',
      bip44CoinType: AppConstants.bscCoinType,
      decimals: 6,
      coinType: CoinType.bep20,
      contractAddress: AppConstants.usdtBep20Contract,
      parentCoinId: AppConstants.coinBnb,
      iconPath: 'assets/coins/usdt.png',
      colorHex: '#26A17B',
      supportedAddressTypes: [AddressType.standard],
    ),
  ];

  /// 获取所有支持的币种
  static List<CoinInfo> getAll() => List.unmodifiable(_coins);

  /// 根据ID获取币种信息
  static CoinInfo? getById(String id) {
    try {
      return _coins.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 获取所有原生币种
  static List<CoinInfo> getNativeCoins() =>
      _coins.where((c) => c.coinType == CoinType.native).toList();

  /// 获取某条链上的代币
  static List<CoinInfo> getTokensByParent(String parentCoinId) =>
      _coins.where((c) => c.parentCoinId == parentCoinId).toList();

  /// 根据币种ID获取颜色
  static Color getCoinColor(String coinId) {
    final coin = getById(coinId);
    if (coin?.colorHex != null) {
      final hex = coin!.colorHex!.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    return const Color(0xFF1A73E8);
  }
}
