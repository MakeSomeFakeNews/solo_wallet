import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/export.dart';
import 'package:pointycastle/ecc/ecc_fp.dart' as fp;
import '../coin_interface.dart';
import '../../models/coin_info.dart';
import '../../models/transaction.dart';
import '../../values/app_constants.dart';

/// TRON (TRX) 币种实现
class TrxCoin implements CoinInterface {
  @override
  CoinInfo get info => const CoinInfo(
        id: AppConstants.coinTrx,
        symbol: 'TRX',
        name: 'TRON',
        bip44CoinType: AppConstants.trxCoinType,
        decimals: 6,
        coinType: CoinType.native,
        iconPath: 'assets/coins/trx.png',
        colorHex: '#E50914',
      );

  @override
  int get coinType => AppConstants.trxCoinType;

  @override
  String derivationPath(int addressIndex) {
    return "m/44'/${AppConstants.trxCoinType}'/0'/0/$addressIndex";
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
      throw Exception('TRX address derivation failed: $e');
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
        // Uncompressed: skip 0x04 prefix
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

      // Add 0x41 prefix (TRON mainnet)
      final withPrefix = Uint8List(21);
      withPrefix[0] = 0x41;
      withPrefix.setRange(1, 21, addressBytes);

      // Base58Check encode
      return _base58CheckEncode(withPrefix);
    } catch (e) {
      throw Exception('TRX address derivation from public key failed: $e');
    }
  }

  @override
  bool validateAddress(String address) {
    try {
      if (address.isEmpty || !address.startsWith('T')) return false;
      if (address.length < 25 || address.length > 34) return false;

      // Base58Check decode and verify
      final decoded = _base58Decode(address);
      if (decoded.length != 25) return false;

      // Check prefix is 0x41
      if (decoded[0] != 0x41) return false;

      // Verify checksum
      final payload = decoded.sublist(0, 21);
      final checksum = decoded.sublist(21);
      final expectedChecksum = _doubleSha256(payload).sublist(0, 4);
      for (int i = 0; i < 4; i++) {
        if (checksum[i] != expectedChecksum[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> buildUnsignedTransaction(
    UnsignedTransactionParams params,
  ) async {
    try {
      final ownerAddress = _addressToBytes(params.fromAddress);
      final toAddress = _addressToBytes(params.toAddress);
      final amount = params.amount;

      // Check if this is a TRC20 transfer
      final contractAddress = params.extra?['contractAddress'] as String?;

      if (contractAddress != null) {
        return _buildTrc20Transaction(
          ownerAddress: ownerAddress,
          contractAddressHex: _addressToHex(contractAddress),
          toAddressHex: _addressToHex(params.toAddress),
          amount: amount,
          params: params,
        );
      }

      // Build TransferContract (simplified protobuf encoding)
      final transferContract = _encodeTransferContract(
        ownerAddress: ownerAddress,
        toAddress: toAddress,
        amount: amount,
      );

      // Build Transaction raw data
      final timestamp = params.extra?['timestamp'] as int? ??
          DateTime.now().millisecondsSinceEpoch;
      final expiration = params.extra?['expiration'] as int? ??
          (timestamp + 60 * 60 * 1000); // 1 hour
      final refBlockBytes =
          params.extra?['refBlockBytes'] as String? ?? '0000';
      final refBlockHash =
          params.extra?['refBlockHash'] as String? ?? '0000000000000000';

      final rawData = _encodeTransactionRawData(
        contractType: 1, // TransferContract
        contractData: transferContract,
        timestamp: timestamp,
        expiration: expiration,
        refBlockBytes: _hexDecode(refBlockBytes),
        refBlockHash: _hexDecode(refBlockHash),
      );

      // Hash for signing
      final txHash = crypto.sha256.convert(rawData).bytes;

      return {
        'unsignedData': Uint8List.fromList(txHash),
        'metadata': {
          'rawData': _hexEncode(rawData),
          'timestamp': timestamp,
          'expiration': expiration,
          'contractType': 'TransferContract',
        },
      };
    } catch (e) {
      throw Exception('TRX transaction build failed: $e');
    }
  }

  @override
  String signTransaction(
    Map<String, dynamic> unsignedData,
    Uint8List privateKey,
  ) {
    try {
      final hash = unsignedData['unsignedData'] as Uint8List;
      final metadata = unsignedData['metadata'] as Map<String, dynamic>;
      final rawDataHex = metadata['rawData'] as String;

      // Sign the hash with ECDSA
      final signature = _signWithRecovery(hash, privateKey);

      // Encode as a simplified transaction envelope
      final result = <String, dynamic>{
        'rawData': rawDataHex,
        'signature': _hexEncode(signature),
        'txID': _hexEncode(hash),
      };

      return json.encode(result);
    } catch (e) {
      throw Exception('TRX transaction signing failed: $e');
    }
  }

  @override
  Map<String, dynamic>? parsePaymentUri(String uri) {
    try {
      if (!uri.toLowerCase().startsWith('tron:')) return null;

      final withoutScheme = uri.substring(5);
      String address;
      Map<String, String> queryParams = {};

      final questionIndex = withoutScheme.indexOf('?');
      if (questionIndex == -1) {
        address = withoutScheme;
      } else {
        address = withoutScheme.substring(0, questionIndex);
        queryParams =
            Uri.splitQueryString(withoutScheme.substring(questionIndex + 1));
      }

      if (!validateAddress(address)) return null;

      final result = <String, dynamic>{
        'address': address,
      };

      if (queryParams.containsKey('amount')) {
        result['amount'] = double.tryParse(queryParams['amount']!);
      }
      if (queryParams.containsKey('token')) {
        result['token'] = queryParams['token'];
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BigInt> estimateFee(UnsignedTransactionParams params) async {
    // TRX uses bandwidth/energy model
    // Simplified: 1 TRX = 1,000,000 SUN for basic transfers
    return BigInt.from(1000000);
  }

  // ========== Private Helper Methods ==========

  Uint8List _privateKeyToUncompressedPublicKey(Uint8List privateKey) {
    final params = ECDomainParameters('secp256k1');
    final privKeyBigInt = _bytesToBigInt(privateKey);
    final pubPoint = params.G * privKeyBigInt;
    if (pubPoint == null) throw Exception('Invalid private key');
    return pubPoint.getEncoded(false);
  }

  Uint8List _decompressPublicKey(Uint8List compressed) {
    final params = ECDomainParameters('secp256k1');
    final point = params.curve.decodePoint(compressed);
    if (point == null) throw Exception('Invalid compressed public key');
    return point.getEncoded(false);
  }

  Uint8List _keccak256(Uint8List data) {
    final digest = KeccakDigest(256);
    return digest.process(data);
  }

  Uint8List _doubleSha256(Uint8List data) {
    final first = crypto.sha256.convert(data).bytes;
    final second = crypto.sha256.convert(first).bytes;
    return Uint8List.fromList(second);
  }

  /// TRON 地址 -> 21字节 (0x41 + 20字节)
  Uint8List _addressToBytes(String address) {
    final decoded = _base58Decode(address);
    // Remove checksum, keep first 21 bytes
    return decoded.sublist(0, 21);
  }

  /// TRON 地址 -> hex (不含0x前缀)
  String _addressToHex(String address) {
    final bytes = _addressToBytes(address);
    return _hexEncode(bytes);
  }

  // ========== Simplified Protobuf Encoding ==========

  /// Encode TransferContract
  Uint8List _encodeTransferContract({
    required Uint8List ownerAddress,
    required Uint8List toAddress,
    required BigInt amount,
  }) {
    final buffer = BytesBuilder();
    // field 1: owner_address (bytes), tag = 0x0a
    buffer.addByte(0x0a);
    buffer.addByte(ownerAddress.length);
    buffer.add(ownerAddress);
    // field 2: to_address (bytes), tag = 0x12
    buffer.addByte(0x12);
    buffer.addByte(toAddress.length);
    buffer.add(toAddress);
    // field 3: amount (int64), tag = 0x18
    buffer.addByte(0x18);
    buffer.add(_encodeVarint(amount.toInt()));
    return buffer.toBytes();
  }

  /// Encode Transaction raw_data
  Uint8List _encodeTransactionRawData({
    required int contractType,
    required Uint8List contractData,
    required int timestamp,
    required int expiration,
    required Uint8List refBlockBytes,
    required Uint8List refBlockHash,
  }) {
    final buffer = BytesBuilder();

    // field 1: ref_block_bytes (bytes), tag = 0x0a
    buffer.addByte(0x0a);
    buffer.addByte(refBlockBytes.length);
    buffer.add(refBlockBytes);

    // field 4: ref_block_hash (bytes), tag = 0x22
    buffer.addByte(0x22);
    buffer.addByte(refBlockHash.length);
    buffer.add(refBlockHash);

    // field 8: expiration (int64), tag = 0x40
    buffer.addByte(0x40);
    buffer.add(_encodeVarint(expiration));

    // field 11: contract (repeated), tag = 0x5a
    // Contract message: type + parameter
    final contractMsg = BytesBuilder();
    // field 1: type (enum), tag = 0x08
    contractMsg.addByte(0x08);
    contractMsg.add(_encodeVarint(contractType));
    // field 2: parameter (Any), tag = 0x12
    final anyMsg = _encodeAny(
      'type.googleapis.com/protocol.TransferContract',
      contractData,
    );
    contractMsg.addByte(0x12);
    contractMsg.add(_encodeVarintBytes(anyMsg.length));
    contractMsg.add(anyMsg);

    final contractMsgBytes = contractMsg.toBytes();
    buffer.addByte(0x5a);
    buffer.add(_encodeVarintBytes(contractMsgBytes.length));
    buffer.add(contractMsgBytes);

    // field 14: timestamp (int64), tag = 0x70
    buffer.addByte(0x70);
    buffer.add(_encodeVarint(timestamp));

    return buffer.toBytes();
  }

  /// Encode google.protobuf.Any
  Uint8List _encodeAny(String typeUrl, Uint8List value) {
    final buffer = BytesBuilder();
    // field 1: type_url (string), tag = 0x0a
    final typeUrlBytes = utf8.encode(typeUrl);
    buffer.addByte(0x0a);
    buffer.add(_encodeVarintBytes(typeUrlBytes.length));
    buffer.add(typeUrlBytes);
    // field 2: value (bytes), tag = 0x12
    buffer.addByte(0x12);
    buffer.add(_encodeVarintBytes(value.length));
    buffer.add(value);
    return buffer.toBytes();
  }

  /// Build TRC20 TriggerSmartContract transaction
  Future<Map<String, dynamic>> _buildTrc20Transaction({
    required Uint8List ownerAddress,
    required String contractAddressHex,
    required String toAddressHex,
    required BigInt amount,
    required UnsignedTransactionParams params,
  }) async {
    // Build transfer(address,uint256) calldata
    final methodId = _hexDecode('a9059cbb');
    // Pad toAddress to 32 bytes (remove 0x41 prefix, pad left)
    final toBytes = _hexDecode(toAddressHex);
    final toAddrClean = toBytes.sublist(1); // remove 0x41
    final paddedTo = Uint8List(32);
    paddedTo.setRange(12, 32, toAddrClean);

    // Pad amount to 32 bytes
    final amountBytes = _bigIntToBytes32(amount);

    final calldata = Uint8List(4 + 32 + 32);
    calldata.setAll(0, methodId);
    calldata.setAll(4, paddedTo);
    calldata.setAll(36, amountBytes);

    // Encode TriggerSmartContract
    final contractBytes = _hexDecode(contractAddressHex);
    final triggerContract = BytesBuilder();
    // field 1: owner_address
    triggerContract.addByte(0x0a);
    triggerContract.addByte(ownerAddress.length);
    triggerContract.add(ownerAddress);
    // field 2: contract_address
    triggerContract.addByte(0x12);
    triggerContract.addByte(contractBytes.length);
    triggerContract.add(contractBytes);
    // field 4: data (calldata)
    triggerContract.addByte(0x22);
    triggerContract.add(_encodeVarintBytes(calldata.length));
    triggerContract.add(calldata);

    final triggerContractData = triggerContract.toBytes();

    final timestamp = params.extra?['timestamp'] as int? ??
        DateTime.now().millisecondsSinceEpoch;
    final expiration = params.extra?['expiration'] as int? ??
        (timestamp + 60 * 60 * 1000);
    final refBlockBytes = params.extra?['refBlockBytes'] as String? ?? '0000';
    final refBlockHash =
        params.extra?['refBlockHash'] as String? ?? '0000000000000000';

    // TriggerSmartContract type = 31
    final rawData = _encodeTransactionRawData(
      contractType: 31,
      contractData: triggerContractData,
      timestamp: timestamp,
      expiration: expiration,
      refBlockBytes: _hexDecode(refBlockBytes),
      refBlockHash: _hexDecode(refBlockHash),
    );

    final txHash = crypto.sha256.convert(rawData).bytes;

    return {
      'unsignedData': Uint8List.fromList(txHash),
      'metadata': {
        'rawData': _hexEncode(rawData),
        'timestamp': timestamp,
        'expiration': expiration,
        'contractType': 'TriggerSmartContract',
      },
    };
  }

  /// ECDSA sign with recovery byte (65 bytes: r + s + v)
  Uint8List _signWithRecovery(Uint8List hash, Uint8List privateKey) {
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

    // Determine recovery ID
    final privKeyBigInt = _bytesToBigInt(privateKey);
    final expectedPubPoint = params.G * privKeyBigInt;
    int recId = 0;
    for (int i = 0; i < 2; i++) {
      try {
        final recovered = _recoverPublicKey(hash, sig.r, s, i, params);
        if (recovered != null && recovered == expectedPubPoint) {
          recId = i;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    // Encode: r(32) + s(32) + v(1)
    final result = Uint8List(65);
    final rBytes = _bigIntToBytes32(sig.r);
    final sBytes = _bigIntToBytes32(s);
    result.setRange(0, 32, rBytes);
    result.setRange(32, 64, sBytes);
    result[64] = recId + 27;
    return result;
  }

  ECPoint? _recoverPublicKey(
      Uint8List hash, BigInt r, BigInt s, int recId, ECDomainParameters params) {
    final n = params.n;
    final curve = params.curve;
    final p = (curve as fp.ECCurve).q!;
    final a = curve.a!.toBigInteger()!;
    final b = curve.b!.toBigInteger()!;

    final x = r + BigInt.from(recId ~/ 2) * n;
    if (x >= p) return null;

    final y2 = (x.modPow(BigInt.from(3), p) + a * x + b) % p;
    var y = y2.modPow((p + BigInt.one) >> 2, p);

    if ((y.isOdd) != (recId % 2 == 1)) {
      y = p - y;
    }

    final rPoint = params.curve.createPoint(x, y);
    final e = _bytesToBigInt(hash);
    final rInv = r.modInverse(n);

    final rs = rPoint * s;
    final ge = params.G * (n - e);
    if (rs == null || ge == null) return null;
    final sum = rs + ge;
    if (sum == null) return null;
    return sum * rInv;
  }

  // ========== Base58 ==========

  static const _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  String _base58CheckEncode(Uint8List payload) {
    final checksum = _doubleSha256(payload).sublist(0, 4);
    final data = Uint8List(payload.length + 4);
    data.setAll(0, payload);
    data.setAll(payload.length, checksum);
    return _base58Encode(data);
  }

  String _base58Encode(Uint8List data) {
    var number = _bytesToBigInt(data);
    final result = StringBuffer();
    final base = BigInt.from(58);

    while (number > BigInt.zero) {
      final remainder = number % base;
      number = number ~/ base;
      result.write(_base58Alphabet[remainder.toInt()]);
    }

    for (final byte in data) {
      if (byte == 0) {
        result.write('1');
      } else {
        break;
      }
    }

    return result.toString().split('').reversed.join('');
  }

  Uint8List _base58Decode(String input) {
    var number = BigInt.zero;
    final base = BigInt.from(58);

    for (final char in input.split('')) {
      final index = _base58Alphabet.indexOf(char);
      if (index == -1) throw Exception('Invalid Base58 character: $char');
      number = number * base + BigInt.from(index);
    }

    final bytes = _bigIntToMinBytes(number);

    int leadingZeros = 0;
    for (final char in input.split('')) {
      if (char == '1') {
        leadingZeros++;
      } else {
        break;
      }
    }

    final result = Uint8List(leadingZeros + bytes.length);
    result.setRange(leadingZeros, result.length, bytes);
    return result;
  }

  // ========== Utility Methods ==========

  Uint8List _encodeVarint(int value) {
    final bytes = <int>[];
    var v = value;
    while (v > 0x7f) {
      bytes.add((v & 0x7f) | 0x80);
      v >>= 7;
    }
    bytes.add(v & 0x7f);
    return Uint8List.fromList(bytes);
  }

  Uint8List _encodeVarintBytes(int length) {
    return _encodeVarint(length);
  }

  Uint8List _bigIntToBytes32(BigInt value) {
    final bytes = _bigIntToMinBytes(value);
    final result = Uint8List(32);
    result.setRange(32 - bytes.length, 32, bytes);
    return result;
  }

  List<int> _bigIntToMinBytes(BigInt value) {
    if (value == BigInt.zero) return [0];
    final bytes = <int>[];
    var v = value;
    while (v > BigInt.zero) {
      bytes.insert(0, (v & BigInt.from(0xff)).toInt());
      v >>= 8;
    }
    return bytes;
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
