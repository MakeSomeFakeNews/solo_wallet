import '../models/coin_info.dart';
import '../models/transaction.dart';
import '../values/app_constants.dart';
import 'coin_interface.dart';
import 'coins/btc_coin.dart';
import 'coins/eth_coin.dart';
import 'coins/trx_coin.dart';
import 'coins/bsc_coin.dart';

/// 币种注册中心 - 管理所有支持的币种
class CoinRegistry {
  static final Map<String, CoinInterface> _coins = {};
  static bool _initialized = false;

  /// 初始化默认币种
  static void init() {
    if (_initialized) return;

    // 注册主链原生币种
    register(BtcCoin());
    register(EthCoin());
    register(TrxCoin());
    register(BscCoin());

    // 注册 USDT 代币（ERC20, TRC20, BEP20）
    _registerDefaultTokens();

    _initialized = true;
  }

  /// 注册币种
  static void register(CoinInterface coin) {
    _coins[coin.info.id] = coin;
  }

  /// 获取币种实现
  static CoinInterface? get(String coinId) {
    _ensureInitialized();
    return _coins[coinId];
  }

  /// 获取所有已注册的币种
  static List<CoinInterface> getAll() {
    _ensureInitialized();
    return _coins.values.toList();
  }

  /// 检查币种是否已注册
  static bool isRegistered(String coinId) {
    _ensureInitialized();
    return _coins.containsKey(coinId);
  }

  /// 注册自定义代币
  /// [tokenInfo] 代币信息
  /// [parentCoinId] 父链币种ID（如 'eth', 'trx', 'bnb'）
  static void registerCustomToken(CoinInfo tokenInfo, String parentCoinId) {
    final parentCoin = _coins[parentCoinId];
    if (parentCoin == null) {
      throw Exception('Parent coin "$parentCoinId" not registered');
    }

    // 为代币创建一个包装器，复用父链的加密能力
    final tokenCoin = _TokenCoinWrapper(
      tokenInfo: tokenInfo,
      parentCoin: parentCoin,
    );
    _coins[tokenInfo.id] = tokenCoin;
  }

  /// 获取所有主链原生币种
  static List<CoinInterface> getNativeCoins() {
    _ensureInitialized();
    return _coins.values
        .where((c) => c.info.coinType == CoinType.native)
        .toList();
  }

  /// 获取指定主链下的所有代币
  static List<CoinInterface> getTokens(String parentCoinId) {
    _ensureInitialized();
    return _coins.values
        .where((c) => c.info.parentCoinId == parentCoinId)
        .toList();
  }

  /// 确保已初始化
  static void _ensureInitialized() {
    if (!_initialized) init();
  }

  /// 注册默认代币
  static void _registerDefaultTokens() {
    // USDT (ERC20) - on Ethereum
    registerCustomToken(
      const CoinInfo(
        id: AppConstants.coinUsdtErc20,
        symbol: 'USDT',
        name: 'Tether USD (ERC20)',
        bip44CoinType: AppConstants.ethCoinType,
        decimals: 6,
        coinType: CoinType.erc20,
        contractAddress: AppConstants.usdtErc20Contract,
        parentCoinId: AppConstants.coinEth,
        iconPath: 'assets/coins/usdt.png',
        colorHex: '#26A17B',
      ),
      AppConstants.coinEth,
    );

    // USDT (TRC20) - on TRON
    registerCustomToken(
      const CoinInfo(
        id: AppConstants.coinUsdtTrc20,
        symbol: 'USDT',
        name: 'Tether USD (TRC20)',
        bip44CoinType: AppConstants.trxCoinType,
        decimals: 6,
        coinType: CoinType.trc20,
        contractAddress: AppConstants.usdtTrc20Contract,
        parentCoinId: AppConstants.coinTrx,
        iconPath: 'assets/coins/usdt.png',
        colorHex: '#26A17B',
      ),
      AppConstants.coinTrx,
    );

    // USDT (BEP20) - on BSC
    registerCustomToken(
      const CoinInfo(
        id: AppConstants.coinUsdtBep20,
        symbol: 'USDT',
        name: 'Tether USD (BEP20)',
        bip44CoinType: AppConstants.bscCoinType,
        decimals: 18,
        coinType: CoinType.bep20,
        contractAddress: AppConstants.usdtBep20Contract,
        parentCoinId: AppConstants.coinBnb,
        iconPath: 'assets/coins/usdt.png',
        colorHex: '#26A17B',
      ),
      AppConstants.coinBnb,
    );
  }
}

/// 代币包装器 - 复用父链的加密能力，仅修改币种信息和交易构建
class _TokenCoinWrapper implements CoinInterface {
  final CoinInfo tokenInfo;
  final CoinInterface parentCoin;

  _TokenCoinWrapper({
    required this.tokenInfo,
    required this.parentCoin,
  });

  @override
  CoinInfo get info => tokenInfo;

  @override
  int get coinType => parentCoin.coinType;

  @override
  String derivationPath(int addressIndex) => parentCoin.derivationPath(addressIndex);

  @override
  String deriveAddress(
    dynamic privateKey, {
    AddressType type = AddressType.standard,
  }) =>
      parentCoin.deriveAddress(privateKey, type: type);

  @override
  String deriveAddressFromPublicKey(
    dynamic publicKey, {
    AddressType type = AddressType.standard,
  }) =>
      parentCoin.deriveAddressFromPublicKey(publicKey, type: type);

  @override
  bool validateAddress(String address) => parentCoin.validateAddress(address);

  @override
  Future<Map<String, dynamic>> buildUnsignedTransaction(
    UnsignedTransactionParams params,
  ) {
    // Inject contract address into extra params for token transfers
    final extra = Map<String, dynamic>.from(params.extra ?? {});
    extra['contractAddress'] = tokenInfo.contractAddress;

    final tokenParams = UnsignedTransactionParams(
      coinId: params.coinId,
      fromAddress: params.fromAddress,
      toAddress: params.toAddress,
      amount: params.amount,
      feeParams: params.feeParams,
      extra: extra,
    );
    return parentCoin.buildUnsignedTransaction(tokenParams);
  }

  @override
  String signTransaction(
    Map<String, dynamic> unsignedData,
    dynamic privateKey,
  ) =>
      parentCoin.signTransaction(unsignedData, privateKey);

  @override
  Map<String, dynamic>? parsePaymentUri(String uri) =>
      parentCoin.parsePaymentUri(uri);

  @override
  Future<BigInt> estimateFee(UnsignedTransactionParams params) =>
      parentCoin.estimateFee(params);
}
