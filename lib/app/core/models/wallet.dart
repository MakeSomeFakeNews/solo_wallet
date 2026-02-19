import 'account.dart';

/// 钱包类型
enum WalletType {
  hd,        // HD钱包（助记词派生）
  privateKey, // 私钥导入
  watchOnly,  // 观察钱包（仅公钥）
}

/// 主钱包，管理所有币种账户
class Wallet {
  final String id;
  String name;
  final WalletType type;
  final DateTime createdAt;
  final List<Account> accounts; // 各币种账户
  final List<String> activeCoins; // 已激活的币种ID列表

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.accounts = const [],
    this.activeCoins = const [],
  });

  bool get isWatchOnly => type == WalletType.watchOnly;

  /// 获取指定币种的账户
  Account? getAccount(String coinId) {
    try {
      return accounts.firstWhere((a) => a.coinId == coinId);
    } catch (_) {
      return null;
    }
  }

  /// 获取指定币种的地址
  String? getAddress(String coinId) => getAccount(coinId)?.address;

  Wallet copyWith({
    String? name,
    List<Account>? accounts,
    List<String>? activeCoins,
  }) {
    return Wallet(
      id: id,
      name: name ?? this.name,
      type: type,
      createdAt: createdAt,
      accounts: accounts ?? this.accounts,
      activeCoins: activeCoins ?? this.activeCoins,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'accounts': accounts.map((a) => a.toJson()).toList(),
    'activeCoins': activeCoins,
  };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] as String,
    name: json['name'] as String,
    type: WalletType.values[json['type'] as int? ?? 0],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    accounts: (json['accounts'] as List? ?? [])
        .map((a) => Account.fromJson(a as Map<String, dynamic>))
        .toList(),
    activeCoins: List<String>.from(json['activeCoins'] as List? ?? []),
  );
}
