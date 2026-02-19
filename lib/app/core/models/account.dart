import 'coin_info.dart';

/// 单个币种账户，代表一个派生地址
class Account {
  final String id;              // 唯一ID: coinId + '_' + addressIndex
  final String coinId;          // 对应的币种ID
  final String address;         // 当前活跃地址
  final int addressIndex;       // BIP44地址索引 (address_index)
  final String derivationPath;  // 完整派生路径
  final String? extendedPublicKey; // 扩展公钥 xpub
  final AddressType addressType;// 地址类型
  final bool isWatchOnly;       // 是否观察模式（无私钥）
  final List<String> usedAddresses; // 已使用过的地址列表

  Account({
    required this.id,
    required this.coinId,
    required this.address,
    this.addressIndex = 0,
    required this.derivationPath,
    this.extendedPublicKey,
    this.addressType = AddressType.standard,
    this.isWatchOnly = false,
    this.usedAddresses = const [],
  });

  Account copyWith({
    String? address,
    int? addressIndex,
    String? extendedPublicKey,
    AddressType? addressType,
    List<String>? usedAddresses,
  }) {
    return Account(
      id: id,
      coinId: coinId,
      address: address ?? this.address,
      addressIndex: addressIndex ?? this.addressIndex,
      derivationPath: derivationPath,
      extendedPublicKey: extendedPublicKey ?? this.extendedPublicKey,
      addressType: addressType ?? this.addressType,
      isWatchOnly: isWatchOnly,
      usedAddresses: usedAddresses ?? this.usedAddresses,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'coinId': coinId,
    'address': address,
    'addressIndex': addressIndex,
    'derivationPath': derivationPath,
    'extendedPublicKey': extendedPublicKey,
    'addressType': addressType.index,
    'isWatchOnly': isWatchOnly,
    'usedAddresses': usedAddresses,
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'] as String,
    coinId: json['coinId'] as String,
    address: json['address'] as String,
    addressIndex: json['addressIndex'] as int? ?? 0,
    derivationPath: json['derivationPath'] as String,
    extendedPublicKey: json['extendedPublicKey'] as String?,
    addressType: AddressType.values[json['addressType'] as int? ?? AddressType.standard.index],
    isWatchOnly: json['isWatchOnly'] as bool? ?? false,
    usedAddresses: List<String>.from(json['usedAddresses'] as List? ?? []),
  );
}
