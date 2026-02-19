import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/ecc/ecc_fp.dart' as fp;
import '../coin_interface.dart';
import '../../models/coin_info.dart';
import '../../models/transaction.dart';
import '../../values/app_constants.dart';

/// Ethereum (ETH) 币种实现
class EthCoin implements CoinInterface {
  @override
  CoinInfo get info => const CoinInfo(
        id: AppConstants.coinEth,
        symbol: 'ETH',
        name: 'Ethereum',
        bip44CoinType: AppConstants.ethCoinType,
        decimals: 18,
        coinType: CoinType.native,
        iconPath: 'assets/coins/eth.png',
        colorHex: '#627EEA',
      );

  @override
  int get coinType => AppConstants.ethCoinType;

  /// 子类可覆盖的 chainId
  int get chainId => AppConstants.ethChainId;

  @override
  String derivationPath(int addressIndex) {
    return "m/44'/${AppConstants.ethCoinType}'/0'/0/$addressIndex";
  }

  @override
  String deriveAddress(
    Uint8List privateKey, {
    AddressType type = AddressType.standard,
  }) {
    try {
      final publicKey = _privateKeyToUncompressedPublicKey(privateKey);
      return deriveAddressFromPublicKey(publicKey, type: type);
    } catch (e) {
      throw Exception('ETH address derivation failed: $e');
    }
  }

  @override
  String deriveAddressFromPublicKey(
    Uint8List publicKey, {
    AddressType type = AddressType.standard,
  }) {
    try {
      Uint8List pubKeyBytes;
      if (publicKey.length == 65) {
        // Uncompressed: remove 0x04 prefix
        pubKeyBytes = publicKey.sublist(1);
      } else if (publicKey.length == 64) {
        pubKeyBytes = publicKey;
      } else if (publicKey.length == 33) {
        // Compressed: decompress first
        pubKeyBytes = _decompressPublicKey(publicKey).sublist(1);
      } else {
        throw Exception('Invalid public key length: ${publicKey.length}');
      }

      // keccak256 of the 64-byte public key
      final hash = _keccak256(pubKeyBytes);

      // Take last 20 bytes
      final addressBytes = hash.sublist(12);

      // EIP-55 checksum encoding
      return _toEip55Address(addressBytes);
    } catch (e) {
      throw Exception('ETH address derivation from public key failed: $e');
    }
  }

  @override
  bool validateAddress(String address) {
    try {
      if (!address.startsWith('0x') && !address.startsWith('0X')) {
        return false;
      }
      final hex = address.substring(2);
      if (hex.length != 40) return false;
      // Check valid hex characters
      return RegExp(r'^[0-9a-fA-F]{40}$').hasMatch(hex);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> buildUnsignedTransaction(
    UnsignedTransactionParams params,
  ) async {
    try {
      final nonce = params.feeParams['nonce'] as int? ?? 0;
      final txChainId = params.feeParams['chainId'] as int? ?? chainId;

      // Check if EIP-1559 parameters are provided
      final maxFeePerGas = params.feeParams['maxFeePerGas'] as BigInt?;
      final maxPriorityFeePerGas =
          params.feeParams['maxPriorityFeePerGas'] as BigInt?;
      final gasPrice = params.feeParams['gasPrice'] as BigInt?;
      final gasLimit = params.feeParams['gasLimit'] as int? ??
          AppConstants.defaultEthGasLimit;

      // Check if this is an ERC20 transfer
      final contractAddress = params.extra?['contractAddress'] as String?;
      Uint8List? data;
      String toAddress;
      BigInt value;

      if (contractAddress != null) {
        // ERC20 transfer
        data = buildErc20Transfer(
          params.toAddress,
          params.amount,
        );
        toAddress = contractAddress;
        value = BigInt.zero;
      } else {
        toAddress = params.toAddress;
        value = params.amount;
        final extraData = params.extra?['data'] as String?;
        if (extraData != null) {
          data = _hexDecode(extraData);
        }
      }

      final bool isEip1559 =
          maxFeePerGas != null && maxPriorityFeePerGas != null;

      Map<String, dynamic> txData;

      if (isEip1559) {
        // EIP-1559 transaction (type 2)
        txData = {
          'type': 2,
          'chainId': txChainId,
          'nonce': nonce,
          'maxPriorityFeePerGas': maxPriorityFeePerGas.toString(),
          'maxFeePerGas': maxFeePerGas.toString(),
          'gasLimit': gasLimit,
          'to': toAddress,
          'value': value.toString(),
          'data': data != null ? _hexEncode(data) : '',
        };
      } else {
        // Legacy transaction
        final gp = gasPrice ??
            BigInt.from(
                (AppConstants.defaultGasPriceGwei * 1e9).round());
        txData = {
          'type': 0,
          'nonce': nonce,
          'gasPrice': gp.toString(),
          'gasLimit': gasLimit,
          'to': toAddress,
          'value': value.toString(),
          'data': data != null ? _hexEncode(data) : '',
          'chainId': txChainId,
        };
      }

      // RLP encode for signing
      final rlpEncoded = isEip1559
          ? _rlpEncodeEip1559ForSigning(txData)
          : _rlpEncodeLegacyForSigning(txData);

      return {
        'unsignedData': rlpEncoded,
        'metadata': {
          'txData': txData,
          'isEip1559': isEip1559,
          'chainId': txChainId,
        },
      };
    } catch (e) {
      throw Exception('ETH transaction build failed: $e');
    }
  }

  @override
  String signTransaction(
    Map<String, dynamic> unsignedData,
    Uint8List privateKey,
  ) {
    try {
      final metadata = unsignedData['metadata'] as Map<String, dynamic>;
      final txData = metadata['txData'] as Map<String, dynamic>;
      final isEip1559 = metadata['isEip1559'] as bool;
      final txChainId = metadata['chainId'] as int;

      // Hash the unsigned transaction
      final unsignedBytes = unsignedData['unsignedData'] as Uint8List;
      final hash = _keccak256(unsignedBytes);

      // ECDSA sign
      final signature = _signECDSA(hash, privateKey);
      final r = signature[0];
      final s = signature[1];
      final v = _calculateV(hash, r, s, privateKey, txChainId, isEip1559);

      if (isEip1559) {
        // EIP-1559 signed transaction
        return _encodeSignedEip1559Tx(txData, r, s, v);
      } else {
        // Legacy signed transaction
        return _encodeSignedLegacyTx(txData, r, s, v);
      }
    } catch (e) {
      throw Exception('ETH transaction signing failed: $e');
    }
  }

  @override
  Map<String, dynamic>? parsePaymentUri(String uri) {
    try {
      if (!uri.toLowerCase().startsWith('ethereum:')) return null;

      final withoutScheme = uri.substring(9);
      String address;
      int? parsedChainId;
      String? functionName;
      Map<String, String> queryParams = {};

      // Parse ethereum:address@chainId/functionName?params
      var remaining = withoutScheme;

      // Extract query parameters
      final questionIndex = remaining.indexOf('?');
      if (questionIndex != -1) {
        queryParams = Uri.splitQueryString(remaining.substring(questionIndex + 1));
        remaining = remaining.substring(0, questionIndex);
      }

      // Extract function name
      final slashIndex = remaining.indexOf('/');
      if (slashIndex != -1) {
        functionName = remaining.substring(slashIndex + 1);
        remaining = remaining.substring(0, slashIndex);
      }

      // Extract chain ID
      final atIndex = remaining.indexOf('@');
      if (atIndex != -1) {
        parsedChainId = int.tryParse(remaining.substring(atIndex + 1));
        remaining = remaining.substring(0, atIndex);
      }

      address = remaining;
      if (!validateAddress(address)) return null;

      final result = <String, dynamic>{
        'address': address,
      };

      if (parsedChainId != null) result['chainId'] = parsedChainId;
      if (functionName != null) result['functionName'] = functionName;
      if (queryParams.containsKey('value')) {
        result['value'] = BigInt.tryParse(queryParams['value']!);
      }
      if (queryParams.containsKey('uint256')) {
        result['amount'] = BigInt.tryParse(queryParams['uint256']!);
      }
      if (queryParams.containsKey('gasLimit')) {
        result['gasLimit'] = int.tryParse(queryParams['gasLimit']!);
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BigInt> estimateFee(UnsignedTransactionParams params) async {
    try {
      final gasPrice = params.feeParams['gasPrice'] as BigInt? ??
          BigInt.from((AppConstants.defaultGasPriceGwei * 1e9).round());
      final gasLimit = params.feeParams['gasLimit'] as int? ??
          AppConstants.defaultEthGasLimit;
      return gasPrice * BigInt.from(gasLimit);
    } catch (e) {
      throw Exception('ETH fee estimation failed: $e');
    }
  }

  /// 构建 ERC20 transfer calldata
  /// transfer(address,uint256) = 0xa9059cbb
  Uint8List buildErc20Transfer(String toAddress, BigInt amount) {
    final methodId = _hexDecode('a9059cbb');
    final addressBytes = _hexDecode(toAddress.substring(2)).toList();
    // Pad address to 32 bytes
    final paddedAddress = List<int>.filled(32, 0);
    paddedAddress.setRange(12, 32, addressBytes);

    // Encode amount as 32-byte big-endian
    final amountBytes = _bigIntToBytes32(amount);

    final result = Uint8List(4 + 32 + 32);
    result.setAll(0, methodId);
    result.setAll(4, paddedAddress);
    result.setAll(36, amountBytes);
    return result;
  }

  // ========== Private Helper Methods ==========

  /// 私钥 -> 非压缩公钥 (65 bytes, 0x04 prefix)
  Uint8List _privateKeyToUncompressedPublicKey(Uint8List privateKey) {
    final params = ECDomainParameters('secp256k1');
    final privKeyBigInt = _bytesToBigInt(privateKey);
    final pubPoint = params.G * privKeyBigInt;
    if (pubPoint == null) throw Exception('Invalid private key');
    return pubPoint.getEncoded(false);
  }

  /// 解压缩公钥
  Uint8List _decompressPublicKey(Uint8List compressed) {
    final params = ECDomainParameters('secp256k1');
    final point = params.curve.decodePoint(compressed);
    if (point == null) throw Exception('Invalid compressed public key');
    return point.getEncoded(false);
  }

  /// Keccak-256 哈希
  Uint8List _keccak256(Uint8List data) {
    final digest = KeccakDigest(256);
    return digest.process(data);
  }

  /// EIP-55 地址校验和编码
  String _toEip55Address(Uint8List addressBytes) {
    final hexAddr = _hexEncode(addressBytes);
    final hashHex = _hexEncode(_keccak256(Uint8List.fromList(utf8.encode(hexAddr))));

    final result = StringBuffer('0x');
    for (int i = 0; i < hexAddr.length; i++) {
      final c = hexAddr[i];
      if (int.parse(hashHex[i], radix: 16) >= 8) {
        result.write(c.toUpperCase());
      } else {
        result.write(c.toLowerCase());
      }
    }
    return result.toString();
  }

  /// ECDSA 签名 (secp256k1)
  List<BigInt> _signECDSA(Uint8List hash, Uint8List privateKey) {
    final params = ECDomainParameters('secp256k1');
    final signer = ECDSASigner(null, HMac(SHA256Digest(), 64));
    final privKey = ECPrivateKey(_bytesToBigInt(privateKey), params);
    signer.init(true, PrivateKeyParameter<ECPrivateKey>(privKey));
    final sig = signer.generateSignature(hash) as ECSignature;

    // Enforce low-S
    final halfN = params.n >> 1;
    BigInt s = sig.s;
    if (s > halfN) {
      s = params.n - s;
    }

    return [sig.r, s];
  }

  /// 计算 v 值 (recovery ID)
  int _calculateV(Uint8List hash, BigInt r, BigInt s, Uint8List privateKey,
      int txChainId, bool isEip1559) {
    // Derive public key from private key
    final params = ECDomainParameters('secp256k1');
    final privKeyBigInt = _bytesToBigInt(privateKey);
    final expectedPubPoint = params.G * privKeyBigInt;

    // Try recovery IDs 0 and 1
    for (int recId = 0; recId < 2; recId++) {
      try {
        final recoveredPoint = _recoverPublicKey(hash, r, s, recId);
        if (recoveredPoint != null && recoveredPoint == expectedPubPoint) {
          if (isEip1559) {
            return recId; // EIP-1559: v is just 0 or 1
          } else {
            return recId + txChainId * 2 + 35; // EIP-155
          }
        }
      } catch (_) {
        continue;
      }
    }

    // Default fallback
    return isEip1559 ? 0 : 27 + txChainId * 2 + 8;
  }

  /// EC point recovery
  ECPoint? _recoverPublicKey(
      Uint8List hash, BigInt r, BigInt s, int recId) {
    final params = ECDomainParameters('secp256k1');
    final n = params.n;
    final curve = params.curve;
    final p = (curve as fp.ECCurve).q!;
    final a = curve.a!.toBigInteger()!;
    final b = curve.b!.toBigInteger()!;

    final x = r + BigInt.from(recId ~/ 2) * n;
    if (x >= p) return null;

    // Compute y from x: y^2 = x^3 + ax + b (mod p)
    final y2 = (x.modPow(BigInt.from(3), p) + a * x + b) % p;
    var y = y2.modPow((p + BigInt.one) >> 2, p);

    // Check parity
    if ((y.isOdd) != (recId % 2 == 1)) {
      y = p - y;
    }

    final rPoint = params.curve.createPoint(x, y);
    final e = _bytesToBigInt(hash);
    final rInv = r.modInverse(n);

    // R*s + G*(n-e) then multiply by rInv
    final rs = rPoint * s;
    final ge = params.G * (n - e);
    if (rs == null || ge == null) return null;
    final sum = rs + ge;
    if (sum == null) return null;
    return sum * rInv;
  }

  // ========== RLP Encoding ==========

  /// RLP encode legacy transaction for signing (EIP-155)
  Uint8List _rlpEncodeLegacyForSigning(Map<String, dynamic> txData) {
    final items = [
      _rlpEncodeInt(txData['nonce'] as int),
      _rlpEncodeBigInt(BigInt.parse(txData['gasPrice'].toString())),
      _rlpEncodeInt(txData['gasLimit'] as int),
      _rlpEncodeAddress(txData['to'] as String),
      _rlpEncodeBigInt(BigInt.parse(txData['value'].toString())),
      _rlpEncodeBytes(_hexDecode(txData['data'] as String? ?? '')),
      // EIP-155: chainId, 0, 0
      _rlpEncodeInt(txData['chainId'] as int),
      _rlpEncodeBytes(Uint8List(0)),
      _rlpEncodeBytes(Uint8List(0)),
    ];
    return _rlpEncodeList(items);
  }

  /// RLP encode EIP-1559 transaction for signing
  Uint8List _rlpEncodeEip1559ForSigning(Map<String, dynamic> txData) {
    final items = [
      _rlpEncodeInt(txData['chainId'] as int),
      _rlpEncodeInt(txData['nonce'] as int),
      _rlpEncodeBigInt(BigInt.parse(txData['maxPriorityFeePerGas'].toString())),
      _rlpEncodeBigInt(BigInt.parse(txData['maxFeePerGas'].toString())),
      _rlpEncodeInt(txData['gasLimit'] as int),
      _rlpEncodeAddress(txData['to'] as String),
      _rlpEncodeBigInt(BigInt.parse(txData['value'].toString())),
      _rlpEncodeBytes(_hexDecode(txData['data'] as String? ?? '')),
      _rlpEncodeList([]), // accessList (empty)
    ];
    // Type 2 prefix: 0x02 || RLP(...)
    final rlp = _rlpEncodeList(items);
    final result = Uint8List(1 + rlp.length);
    result[0] = 0x02;
    result.setAll(1, rlp);
    return result;
  }

  /// Encode signed legacy transaction
  String _encodeSignedLegacyTx(
      Map<String, dynamic> txData, BigInt r, BigInt s, int v) {
    final items = [
      _rlpEncodeInt(txData['nonce'] as int),
      _rlpEncodeBigInt(BigInt.parse(txData['gasPrice'].toString())),
      _rlpEncodeInt(txData['gasLimit'] as int),
      _rlpEncodeAddress(txData['to'] as String),
      _rlpEncodeBigInt(BigInt.parse(txData['value'].toString())),
      _rlpEncodeBytes(_hexDecode(txData['data'] as String? ?? '')),
      _rlpEncodeInt(v),
      _rlpEncodeBigInt(r),
      _rlpEncodeBigInt(s),
    ];
    return '0x${_hexEncode(_rlpEncodeList(items))}';
  }

  /// Encode signed EIP-1559 transaction
  String _encodeSignedEip1559Tx(
      Map<String, dynamic> txData, BigInt r, BigInt s, int v) {
    final items = [
      _rlpEncodeInt(txData['chainId'] as int),
      _rlpEncodeInt(txData['nonce'] as int),
      _rlpEncodeBigInt(BigInt.parse(txData['maxPriorityFeePerGas'].toString())),
      _rlpEncodeBigInt(BigInt.parse(txData['maxFeePerGas'].toString())),
      _rlpEncodeInt(txData['gasLimit'] as int),
      _rlpEncodeAddress(txData['to'] as String),
      _rlpEncodeBigInt(BigInt.parse(txData['value'].toString())),
      _rlpEncodeBytes(_hexDecode(txData['data'] as String? ?? '')),
      _rlpEncodeList([]), // accessList
      _rlpEncodeInt(v),
      _rlpEncodeBigInt(r),
      _rlpEncodeBigInt(s),
    ];
    final rlp = _rlpEncodeList(items);
    final result = Uint8List(1 + rlp.length);
    result[0] = 0x02;
    result.setAll(1, rlp);
    return '0x${_hexEncode(result)}';
  }

  // RLP primitive encoding
  Uint8List _rlpEncodeBytes(Uint8List data) {
    if (data.length == 1 && data[0] < 0x80) {
      return data;
    } else if (data.isEmpty) {
      return Uint8List.fromList([0x80]);
    } else if (data.length <= 55) {
      final result = Uint8List(1 + data.length);
      result[0] = 0x80 + data.length;
      result.setAll(1, data);
      return result;
    } else {
      final lenBytes = _intToMinBytes(data.length);
      final result = Uint8List(1 + lenBytes.length + data.length);
      result[0] = 0xb7 + lenBytes.length;
      result.setAll(1, lenBytes);
      result.setAll(1 + lenBytes.length, data);
      return result;
    }
  }

  Uint8List _rlpEncodeInt(int value) {
    if (value == 0) return Uint8List.fromList([0x80]);
    return _rlpEncodeBytes(Uint8List.fromList(_intToMinBytes(value)));
  }

  Uint8List _rlpEncodeBigInt(BigInt value) {
    if (value == BigInt.zero) return Uint8List.fromList([0x80]);
    final bytes = _bigIntToMinBytes(value);
    return _rlpEncodeBytes(Uint8List.fromList(bytes));
  }

  Uint8List _rlpEncodeAddress(String address) {
    final hex = address.startsWith('0x') ? address.substring(2) : address;
    if (hex.isEmpty) return _rlpEncodeBytes(Uint8List(0));
    return _rlpEncodeBytes(_hexDecode(hex));
  }

  Uint8List _rlpEncodeList(List<Uint8List> items) {
    final payload = BytesBuilder();
    for (final item in items) {
      payload.add(item);
    }
    final data = payload.toBytes();

    if (data.length <= 55) {
      final result = Uint8List(1 + data.length);
      result[0] = 0xc0 + data.length;
      result.setAll(1, data);
      return result;
    } else {
      final lenBytes = _intToMinBytes(data.length);
      final result = Uint8List(1 + lenBytes.length + data.length);
      result[0] = 0xf7 + lenBytes.length;
      result.setAll(1, lenBytes);
      result.setAll(1 + lenBytes.length, data);
      return result;
    }
  }

  // ========== Utility Methods ==========

  List<int> _intToMinBytes(int value) {
    if (value == 0) return [];
    final bytes = <int>[];
    var v = value;
    while (v > 0) {
      bytes.insert(0, v & 0xff);
      v >>= 8;
    }
    return bytes;
  }

  List<int> _bigIntToMinBytes(BigInt value) {
    if (value == BigInt.zero) return [];
    final bytes = <int>[];
    var v = value;
    while (v > BigInt.zero) {
      bytes.insert(0, (v & BigInt.from(0xff)).toInt());
      v >>= 8;
    }
    return bytes;
  }

  Uint8List _bigIntToBytes32(BigInt value) {
    final bytes = _bigIntToMinBytes(value);
    final result = Uint8List(32);
    result.setRange(32 - bytes.length, 32, bytes);
    return result;
  }

  BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  String _hexEncode(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  Uint8List _hexDecode(String hex) {
    final str = hex.startsWith('0x') ? hex.substring(2) : hex;
    if (str.isEmpty) return Uint8List(0);
    final result = Uint8List(str.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(str.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}
