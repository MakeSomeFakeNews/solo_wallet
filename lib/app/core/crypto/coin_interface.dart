import 'dart:typed_data';
import '../models/coin_info.dart';
import '../models/transaction.dart';

/// 币种抽象接口 - 所有币种必须实现此接口
abstract class CoinInterface {
  /// 币种基础信息
  CoinInfo get info;

  /// BIP44 coin_type
  int get coinType;

  /// 获取默认派生路径（指定地址索引）
  String derivationPath(int addressIndex);

  /// 从私钥派生地址
  /// [privateKey] 32字节私钥
  /// [type] 地址类型（BTC有多种，ETH/TRX只有standard）
  String deriveAddress(
    Uint8List privateKey, {
    AddressType type = AddressType.standard,
  });

  /// 从公钥派生地址（用于观察钱包）
  String deriveAddressFromPublicKey(
    Uint8List publicKey, {
    AddressType type = AddressType.standard,
  });

  /// 验证地址格式是否合法
  bool validateAddress(String address);

  /// 构建未签名交易（返回需要签名的数据）
  /// 返回 {unsignedData: Uint8List, metadata: Map}
  Future<Map<String, dynamic>> buildUnsignedTransaction(
    UnsignedTransactionParams params,
  );

  /// 使用私钥签名交易，返回已签名的原始交易（十六进制字符串）
  String signTransaction(
    Map<String, dynamic> unsignedData,
    Uint8List privateKey,
  );

  /// 解析二维码中的支付URI
  /// 如 bitcoin:addr?amount=0.01 或 ethereum:addr@1/transfer?...
  Map<String, dynamic>? parsePaymentUri(String uri);

  /// 估算交易手续费
  /// 返回手续费估算值（最小单位）
  Future<BigInt> estimateFee(UnsignedTransactionParams params);
}

/// 币种接口工厂 - 用于创建和注册币种实现
abstract class CoinFactory {
  CoinInterface create(CoinInfo info);
}
