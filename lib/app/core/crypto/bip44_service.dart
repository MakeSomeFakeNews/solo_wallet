import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;

/// BIP44 HD 钱包密钥派生服务
/// 路径格式: m/44'/coinType'/accountIndex'/0/addressIndex
class Bip44Service {
  /// 从种子派生私钥
  /// [seedBytes] 64字节种子
  /// [coinType] BIP44 coin type (0=BTC, 60=ETH, 195=TRX)
  /// [accountIndex] 账户索引，默认0
  /// [addressIndex] 地址索引，默认0
  static Uint8List derivePrivateKey(
    Uint8List seedBytes, {
    required int coinType,
    int accountIndex = 0,
    int addressIndex = 0,
  }) {
    try {
      final root = bip32.BIP32.fromSeed(seedBytes);
      final path = getDerivationPath(
        coinType: coinType,
        accountIndex: accountIndex,
        addressIndex: addressIndex,
      );
      final child = root.derivePath(path);
      if (child.privateKey == null) {
        throw Exception('Failed to derive private key');
      }
      return child.privateKey!;
    } catch (e) {
      throw Exception('Key derivation failed: $e');
    }
  }

  /// 从私钥派生压缩公钥（33字节）
  static Uint8List derivePublicKey(Uint8List privateKey) {
    try {
      // 使用 bip32 节点来推导公钥
      // 构建一个临时节点以获取公钥
      final node = bip32.BIP32.fromPrivateKey(
        privateKey,
        Uint8List(32), // chainCode placeholder
      );
      return node.publicKey;
    } catch (e) {
      throw Exception('Public key derivation failed: $e');
    }
  }

  /// 从种子派生扩展公钥（xpub）
  /// 返回账户级别的 xpub，可用于观察钱包
  static String deriveExtendedPublicKey(
    Uint8List seedBytes, {
    required int coinType,
    int accountIndex = 0,
  }) {
    try {
      final root = bip32.BIP32.fromSeed(seedBytes);
      final accountPath = "m/44'/$coinType'/$accountIndex'";
      final accountNode = root.derivePath(accountPath);
      return accountNode.neutered().toBase58();
    } catch (e) {
      throw Exception('Extended public key derivation failed: $e');
    }
  }

  /// 获取 BIP44 派生路径
  static String getDerivationPath({
    required int coinType,
    int accountIndex = 0,
    int addressIndex = 0,
  }) {
    return "m/44'/$coinType'/$accountIndex'/0/$addressIndex";
  }

  /// 从种子直接获取 bip32 节点（供币种实现内部使用）
  static bip32.BIP32 deriveNode(
    Uint8List seedBytes, {
    required int coinType,
    int accountIndex = 0,
    int addressIndex = 0,
  }) {
    final root = bip32.BIP32.fromSeed(seedBytes);
    final path = getDerivationPath(
      coinType: coinType,
      accountIndex: accountIndex,
      addressIndex: addressIndex,
    );
    return root.derivePath(path);
  }
}
