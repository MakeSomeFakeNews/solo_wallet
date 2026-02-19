import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
// ignore: implementation_imports
import 'package:bip39/src/wordlists/english.dart' as english;

/// BIP39 助记词服务
/// 提供助记词生成、验证、转换为种子等功能
class Bip39Service {
  /// 生成助记词
  /// [strength] 128 = 12个词, 256 = 24个词
  static String generateMnemonic({int strength = 128}) {
    try {
      return bip39.generateMnemonic(strength: strength);
    } catch (e) {
      throw Exception('Failed to generate mnemonic: $e');
    }
  }

  /// 验证助记词是否合法
  static bool validateMnemonic(String mnemonic) {
    try {
      return bip39.validateMnemonic(mnemonic);
    } catch (_) {
      return false;
    }
  }

  /// 将助记词转换为种子（64字节）
  /// [passphrase] 可选密码短语（BIP39 passphrase）
  static Uint8List mnemonicToSeed(String mnemonic, {String passphrase = ''}) {
    try {
      return bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
    } catch (e) {
      throw Exception('Failed to convert mnemonic to seed: $e');
    }
  }

  /// 将助记词字符串拆分为单词列表
  static List<String> mnemonicToWordList(String mnemonic) {
    return mnemonic.trim().split(RegExp(r'\s+'));
  }

  /// 获取BIP39英文词库（2048个单词，用于自动补全）
  static List<String> get wordList => english.WORDLIST;
}
