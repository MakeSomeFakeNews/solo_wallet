/// 币种类型
enum CoinType {
  native,   // 主链原生代币 (BTC, ETH, TRX, BNB)
  erc20,    // ERC20代币
  trc20,    // TRC20代币
  bep20,    // BEP20代币
}

/// 地址类型（主要用于BTC）
enum AddressType {
  legacy,      // P2PKH (1xxx)
  segwit,      // P2WPKH wrapped (3xxx)
  nativeSegwit, // Bech32 (bc1xxx)
  standard,    // 其他链的标准地址
}

/// 币种元数据，描述一种加密货币的基本信息
class CoinInfo {
  final String id;              // 唯一标识 'btc', 'eth', 'usdt_erc20'
  final String symbol;          // 符号 'BTC', 'ETH', 'USDT'
  final String name;            // 全名 'Bitcoin', 'Ethereum'
  final int bip44CoinType;      // BIP44 coin_type
  final int decimals;           // 精度 (BTC=8, ETH=18, USDT=6)
  final CoinType coinType;      // 代币类型
  final String? contractAddress;// 合约地址（代币专用）
  final String? parentCoinId;   // 父链币种ID（代币专用）
  final String iconPath;        // 本地图标路径
  final String? colorHex;       // 品牌色
  final List<AddressType> supportedAddressTypes; // 支持的地址类型
  final bool isActive;          // 是否已激活显示

  const CoinInfo({
    required this.id,
    required this.symbol,
    required this.name,
    required this.bip44CoinType,
    required this.decimals,
    required this.coinType,
    this.contractAddress,
    this.parentCoinId,
    required this.iconPath,
    this.colorHex,
    this.supportedAddressTypes = const [AddressType.standard],
    this.isActive = false,
  });

  bool get isToken => coinType != CoinType.native;

  /// 格式化金额显示
  String formatAmount(BigInt amount, {int? precision}) {
    final prec = precision ?? decimals;
    if (amount == BigInt.zero) return '0';
    final divisor = BigInt.from(10).pow(decimals);
    final intPart = amount ~/ divisor;
    final fracPart = amount % divisor;
    if (fracPart == BigInt.zero || prec == 0) {
      return intPart.toString();
    }
    final fracStr = fracPart.toString().padLeft(decimals, '0');
    final truncated = fracStr.substring(0, prec.clamp(0, fracStr.length));
    final trimmed = truncated.replaceAll(RegExp(r'0+$'), '');
    if (trimmed.isEmpty) return intPart.toString();
    return '$intPart.$trimmed';
  }

  /// 将用户输入的数量转换为链上最小单位
  BigInt toMinUnit(double amount) {
    final multiplier = BigInt.from(10).pow(decimals);
    final intAmount = (amount * multiplier.toDouble()).round();
    return BigInt.from(intAmount);
  }

  CoinInfo copyWith({bool? isActive}) {
    return CoinInfo(
      id: id,
      symbol: symbol,
      name: name,
      bip44CoinType: bip44CoinType,
      decimals: decimals,
      coinType: coinType,
      contractAddress: contractAddress,
      parentCoinId: parentCoinId,
      iconPath: iconPath,
      colorHex: colorHex,
      supportedAddressTypes: supportedAddressTypes,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'name': name,
    'bip44CoinType': bip44CoinType,
    'decimals': decimals,
    'coinType': coinType.index,
    'contractAddress': contractAddress,
    'parentCoinId': parentCoinId,
    'iconPath': iconPath,
    'colorHex': colorHex,
    'isActive': isActive,
  };

  factory CoinInfo.fromJson(Map<String, dynamic> json) => CoinInfo(
    id: json['id'] as String,
    symbol: json['symbol'] as String,
    name: json['name'] as String,
    bip44CoinType: json['bip44CoinType'] as int,
    decimals: json['decimals'] as int,
    coinType: CoinType.values[json['coinType'] as int],
    contractAddress: json['contractAddress'] as String?,
    parentCoinId: json['parentCoinId'] as String?,
    iconPath: json['iconPath'] as String,
    colorHex: json['colorHex'] as String?,
    isActive: json['isActive'] as bool? ?? false,
  );
}
