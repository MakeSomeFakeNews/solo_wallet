import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/export.dart';
import '../coin_interface.dart';
import '../../models/coin_info.dart';
import '../../models/transaction.dart';
import '../../values/app_constants.dart';

/// Bitcoin (BTC) 币种实现
class BtcCoin implements CoinInterface {
  @override
  CoinInfo get info => const CoinInfo(
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
      );

  @override
  int get coinType => AppConstants.btcCoinType;

  @override
  String derivationPath(int addressIndex) {
    return "m/44'/${AppConstants.btcCoinType}'/0'/0/$addressIndex";
  }

  @override
  String deriveAddress(
    Uint8List privateKey, {
    AddressType type = AddressType.standard,
  }) {
    try {
      final publicKey = _privateKeyToCompressedPublicKey(privateKey);
      return deriveAddressFromPublicKey(publicKey, type: type);
    } catch (e) {
      throw Exception('BTC address derivation failed: $e');
    }
  }

  @override
  String deriveAddressFromPublicKey(
    Uint8List publicKey, {
    AddressType type = AddressType.standard,
  }) {
    try {
      // Default to legacy if standard is passed
      final addrType =
          type == AddressType.standard ? AddressType.legacy : type;

      switch (addrType) {
        case AddressType.legacy:
          return _createP2PKHAddress(publicKey);
        case AddressType.segwit:
          return _createP2SHP2WPKHAddress(publicKey);
        case AddressType.nativeSegwit:
          return _createBech32Address(publicKey);
        default:
          return _createP2PKHAddress(publicKey);
      }
    } catch (e) {
      throw Exception('BTC address derivation from public key failed: $e');
    }
  }

  @override
  bool validateAddress(String address) {
    try {
      if (address.isEmpty) return false;

      // Legacy P2PKH: starts with '1'
      if (address.startsWith('1') && address.length >= 25 && address.length <= 34) {
        return _validateBase58Check(address);
      }

      // P2SH: starts with '3'
      if (address.startsWith('3') && address.length >= 25 && address.length <= 34) {
        return _validateBase58Check(address);
      }

      // Bech32 native segwit: starts with 'bc1'
      if (address.toLowerCase().startsWith('bc1')) {
        return _validateBech32(address);
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> buildUnsignedTransaction(
    UnsignedTransactionParams params,
  ) async {
    try {
      final utxos = params.extra?['utxos'] as List<dynamic>? ?? [];
      final feeRate = params.feeParams['feeRate'] as int? ??
          AppConstants.defaultBtcFeeRate;

      if (utxos.isEmpty) {
        throw Exception('No UTXOs provided');
      }

      // Calculate total input value
      BigInt totalInput = BigInt.zero;
      final inputList = <Map<String, dynamic>>[];
      for (final utxo in utxos) {
        final u = utxo as Map<String, dynamic>;
        totalInput += BigInt.parse(u['value'].toString());
        inputList.add(u);
      }

      // Estimate transaction size (simplified)
      // P2PKH: ~148 bytes per input, ~34 bytes per output, ~10 bytes overhead
      final estimatedSize = inputList.length * 148 + 2 * 34 + 10;
      final fee = BigInt.from(estimatedSize * feeRate);

      final change = totalInput - params.amount - fee;
      if (change < BigInt.zero) {
        throw Exception(
            'Insufficient funds: have $totalInput, need ${params.amount + fee}');
      }

      // Build outputs
      final outputs = <Map<String, dynamic>>[
        {
          'address': params.toAddress,
          'value': params.amount.toString(),
        },
      ];

      // Add change output if significant (dust threshold ~546 satoshis)
      if (change > BigInt.from(546)) {
        outputs.add({
          'address': params.fromAddress,
          'value': change.toString(),
        });
      }

      // Build the unsigned transaction structure
      final unsignedTx = <String, dynamic>{
        'version': 1,
        'inputs': inputList
            .map((u) => {
                  'txHash': u['txHash'],
                  'outputIndex': u['outputIndex'],
                  'value': u['value'].toString(),
                  'scriptPubKey': u['scriptPubKey'] ?? '',
                })
            .toList(),
        'outputs': outputs,
        'locktime': 0,
      };

      return {
        'unsignedData': Uint8List.fromList(utf8.encode(json.encode(unsignedTx))),
        'metadata': {
          'fee': fee.toString(),
          'feeRate': feeRate,
          'estimatedSize': estimatedSize,
          'inputCount': inputList.length,
          'outputCount': outputs.length,
          'txStructure': unsignedTx,
        },
      };
    } catch (e) {
      throw Exception('BTC transaction build failed: $e');
    }
  }

  @override
  String signTransaction(
    Map<String, dynamic> unsignedData,
    Uint8List privateKey,
  ) {
    try {
      final metadata = unsignedData['metadata'] as Map<String, dynamic>;
      final txStructure = metadata['txStructure'] as Map<String, dynamic>;
      final inputs = txStructure['inputs'] as List<dynamic>;
      final outputs = txStructure['outputs'] as List<dynamic>;

      // Build raw transaction
      final buffer = BytesBuilder();

      // Version (4 bytes, little-endian)
      buffer.add(_uint32LE(txStructure['version'] as int));

      // Input count (varint)
      buffer.add(_varint(inputs.length));

      // For each input, create the scriptSig with signature
      for (final input in inputs) {
        final inp = input as Map<String, dynamic>;
        final txHash = _hexDecode(inp['txHash'] as String);
        // Reverse txHash for internal byte order
        buffer.add(txHash.reversed.toList());

        // Output index (4 bytes, little-endian)
        buffer.add(_uint32LE(inp['outputIndex'] as int));

        // Create signature for this input
        // Hash the simplified transaction for signing
        final sigHash = _createSigHash(txStructure, inputs.indexOf(input), inp);
        final signature = _signECDSA(sigHash, privateKey);
        final derSig = _encodeDER(signature);

        // scriptSig: <sig_len+1> <DER_sig> <SIGHASH_ALL> <pubkey_len> <pubkey>
        final pubKey = _privateKeyToCompressedPublicKey(privateKey);
        final sigWithHashType = Uint8List(derSig.length + 1);
        sigWithHashType.setAll(0, derSig);
        sigWithHashType[derSig.length] = 0x01; // SIGHASH_ALL

        final scriptSig = BytesBuilder();
        scriptSig.addByte(sigWithHashType.length);
        scriptSig.add(sigWithHashType);
        scriptSig.addByte(pubKey.length);
        scriptSig.add(pubKey);

        final scriptSigBytes = scriptSig.toBytes();
        buffer.add(_varint(scriptSigBytes.length));
        buffer.add(scriptSigBytes);

        // Sequence (4 bytes, 0xffffffff)
        buffer.add([0xff, 0xff, 0xff, 0xff]);
      }

      // Output count (varint)
      buffer.add(_varint(outputs.length));

      // Outputs
      for (final output in outputs) {
        final out = output as Map<String, dynamic>;
        final value = BigInt.parse(out['value'].toString());
        buffer.add(_uint64LE(value));

        final address = out['address'] as String;
        final scriptPubKey = _addressToScriptPubKey(address);
        buffer.add(_varint(scriptPubKey.length));
        buffer.add(scriptPubKey);
      }

      // Locktime (4 bytes)
      buffer.add(_uint32LE(txStructure['locktime'] as int));

      final rawTx = buffer.toBytes();
      return _hexEncode(rawTx);
    } catch (e) {
      throw Exception('BTC transaction signing failed: $e');
    }
  }

  @override
  Map<String, dynamic>? parsePaymentUri(String uri) {
    try {
      if (!uri.toLowerCase().startsWith('bitcoin:')) return null;

      final withoutScheme = uri.substring(8);
      String address;
      Map<String, String> queryParams = {};

      final questionIndex = withoutScheme.indexOf('?');
      if (questionIndex == -1) {
        address = withoutScheme;
      } else {
        address = withoutScheme.substring(0, questionIndex);
        final queryString = withoutScheme.substring(questionIndex + 1);
        queryParams = Uri.splitQueryString(queryString);
      }

      if (!validateAddress(address)) return null;

      final result = <String, dynamic>{
        'address': address,
      };

      if (queryParams.containsKey('amount')) {
        result['amount'] = double.tryParse(queryParams['amount']!);
      }
      if (queryParams.containsKey('label')) {
        result['label'] = queryParams['label'];
      }
      if (queryParams.containsKey('message')) {
        result['message'] = queryParams['message'];
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BigInt> estimateFee(UnsignedTransactionParams params) async {
    try {
      final feeRate = params.feeParams['feeRate'] as int? ??
          AppConstants.defaultBtcFeeRate;
      final utxos = params.extra?['utxos'] as List<dynamic>? ?? [];
      final inputCount = utxos.isEmpty ? 1 : utxos.length;

      // Estimate: 1 output for recipient + 1 for change
      final estimatedSize = inputCount * 148 + 2 * 34 + 10;
      return BigInt.from(estimatedSize * feeRate);
    } catch (e) {
      throw Exception('BTC fee estimation failed: $e');
    }
  }

  // ========== Private Helper Methods ==========

  /// 私钥 -> 压缩公钥 (33 bytes)
  Uint8List _privateKeyToCompressedPublicKey(Uint8List privateKey) {
    final params = ECDomainParameters('secp256k1');
    final privKeyBigInt = _bytesToBigInt(privateKey);
    final pubPoint = params.G * privKeyBigInt;
    if (pubPoint == null) throw Exception('Invalid private key');
    return pubPoint.getEncoded(true);
  }

  /// P2PKH 地址 (Legacy, 1xxx)
  /// hash160 = RIPEMD160(SHA256(publicKey))
  /// address = Base58Check(0x00 + hash160)
  String _createP2PKHAddress(Uint8List publicKey) {
    final hash160 = _hash160(publicKey);
    final payload = Uint8List(21);
    payload[0] = 0x00; // mainnet prefix
    payload.setRange(1, 21, hash160);
    return _base58CheckEncode(payload);
  }

  /// P2SH-P2WPKH 地址 (SegWit wrapped, 3xxx)
  /// redeemScript = OP_0 <20-byte-key-hash>
  /// scriptHash = HASH160(redeemScript)
  /// address = Base58Check(0x05 + scriptHash)
  String _createP2SHP2WPKHAddress(Uint8List publicKey) {
    final keyHash = _hash160(publicKey);
    // redeemScript: OP_0 (0x00) + pushdata(20) + keyHash
    final redeemScript = Uint8List(22);
    redeemScript[0] = 0x00; // OP_0
    redeemScript[1] = 0x14; // Push 20 bytes
    redeemScript.setRange(2, 22, keyHash);

    final scriptHash = _hash160(redeemScript);
    final payload = Uint8List(21);
    payload[0] = 0x05; // mainnet P2SH prefix
    payload.setRange(1, 21, scriptHash);
    return _base58CheckEncode(payload);
  }

  /// Bech32/P2WPKH 地址 (native segwit, bc1xxx)
  String _createBech32Address(Uint8List publicKey) {
    final keyHash = _hash160(publicKey);
    // Convert to 5-bit groups for bech32
    final converted = _convertBits(keyHash, 8, 5, true);
    // witness version 0 + converted data
    final data = [0, ...converted];
    return _bech32Encode('bc', data);
  }

  /// HASH160 = RIPEMD160(SHA256(data))
  Uint8List _hash160(Uint8List data) {
    final sha256Hash = crypto.sha256.convert(data).bytes;
    final ripemd160 = Digest('RIPEMD-160');
    return ripemd160.process(Uint8List.fromList(sha256Hash));
  }

  /// Double SHA256
  Uint8List _doubleSha256(Uint8List data) {
    final first = crypto.sha256.convert(data).bytes;
    final second = crypto.sha256.convert(first).bytes;
    return Uint8List.fromList(second);
  }

  /// Base58Check 编码
  String _base58CheckEncode(Uint8List payload) {
    final checksum = _doubleSha256(payload).sublist(0, 4);
    final data = Uint8List(payload.length + 4);
    data.setAll(0, payload);
    data.setAll(payload.length, checksum);
    return _base58Encode(data);
  }

  /// Base58Check 解码验证
  bool _validateBase58Check(String address) {
    try {
      final decoded = _base58Decode(address);
      if (decoded.length < 5) return false;
      final payload = decoded.sublist(0, decoded.length - 4);
      final checksum = decoded.sublist(decoded.length - 4);
      final expectedChecksum = _doubleSha256(payload).sublist(0, 4);
      for (int i = 0; i < 4; i++) {
        if (checksum[i] != expectedChecksum[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // Base58 alphabet
  static const _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  /// Base58 编码
  String _base58Encode(Uint8List data) {
    var number = _bytesToBigInt(data);
    final result = StringBuffer();
    final base = BigInt.from(58);
    final zero = BigInt.zero;

    while (number > zero) {
      final remainder = number % base;
      number = number ~/ base;
      result.write(_base58Alphabet[remainder.toInt()]);
    }

    // Preserve leading zeros
    for (final byte in data) {
      if (byte == 0) {
        result.write('1');
      } else {
        break;
      }
    }

    return result.toString().split('').reversed.join('');
  }

  /// Base58 解码
  Uint8List _base58Decode(String input) {
    var number = BigInt.zero;
    final base = BigInt.from(58);

    for (final char in input.split('')) {
      final index = _base58Alphabet.indexOf(char);
      if (index == -1) throw Exception('Invalid Base58 character: $char');
      number = number * base + BigInt.from(index);
    }

    final bytes = _bigIntToBytes(number);

    // Count leading '1's for leading zeros
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

  /// ECDSA签名 (secp256k1)
  List<BigInt> _signECDSA(Uint8List hash, Uint8List privateKey) {
    final params = ECDomainParameters('secp256k1');
    final signer = ECDSASigner(null, HMac(SHA256Digest(), 64));
    final privKey = ECPrivateKey(_bytesToBigInt(privateKey), params);
    signer.init(true, PrivateKeyParameter<ECPrivateKey>(privKey));
    final sig = signer.generateSignature(hash) as ECSignature;

    // Enforce low-S (BIP62)
    final halfN = params.n >> 1;
    BigInt s = sig.s;
    if (s > halfN) {
      s = params.n - s;
    }

    return [sig.r, s];
  }

  /// DER 编码签名
  Uint8List _encodeDER(List<BigInt> signature) {
    final r = _bigIntToBytes(signature[0]);
    final s = _bigIntToBytes(signature[1]);

    // Add leading zero if high bit set (to keep positive)
    final rPadded = (r[0] & 0x80) != 0 ? [0, ...r] : r;
    final sPadded = (s[0] & 0x80) != 0 ? [0, ...s] : s;

    final totalLen = 2 + rPadded.length + 2 + sPadded.length;
    final result = BytesBuilder();
    result.addByte(0x30); // sequence tag
    result.addByte(totalLen);
    result.addByte(0x02); // integer tag
    result.addByte(rPadded.length);
    result.add(rPadded);
    result.addByte(0x02); // integer tag
    result.addByte(sPadded.length);
    result.add(sPadded);

    return result.toBytes();
  }

  /// Create sighash for a specific input (simplified SIGHASH_ALL)
  Uint8List _createSigHash(
    Map<String, dynamic> txStructure,
    int inputIndex,
    Map<String, dynamic> signingInput,
  ) {
    final inputs = txStructure['inputs'] as List<dynamic>;
    final outputs = txStructure['outputs'] as List<dynamic>;

    final buffer = BytesBuilder();

    // Version
    buffer.add(_uint32LE(txStructure['version'] as int));

    // Input count
    buffer.add(_varint(inputs.length));

    // Inputs
    for (int i = 0; i < inputs.length; i++) {
      final inp = inputs[i] as Map<String, dynamic>;
      final txHash = _hexDecode(inp['txHash'] as String);
      buffer.add(txHash.reversed.toList());
      buffer.add(_uint32LE(inp['outputIndex'] as int));

      if (i == inputIndex) {
        // Use scriptPubKey for the input being signed
        final scriptPubKey = inp['scriptPubKey'] as String? ?? '';
        if (scriptPubKey.isNotEmpty) {
          final script = _hexDecode(scriptPubKey);
          buffer.add(_varint(script.length));
          buffer.add(script);
        } else {
          // Fallback: compute scriptPubKey from address
          buffer.addByte(0x00);
        }
      } else {
        buffer.addByte(0x00); // empty script for other inputs
      }

      buffer.add([0xff, 0xff, 0xff, 0xff]); // sequence
    }

    // Output count
    buffer.add(_varint(outputs.length));

    // Outputs
    for (final output in outputs) {
      final out = output as Map<String, dynamic>;
      final value = BigInt.parse(out['value'].toString());
      buffer.add(_uint64LE(value));
      final scriptPubKey = _addressToScriptPubKey(out['address'] as String);
      buffer.add(_varint(scriptPubKey.length));
      buffer.add(scriptPubKey);
    }

    // Locktime
    buffer.add(_uint32LE(txStructure['locktime'] as int));

    // SIGHASH_ALL
    buffer.add(_uint32LE(0x01));

    return _doubleSha256(buffer.toBytes());
  }

  /// 地址 -> scriptPubKey
  Uint8List _addressToScriptPubKey(String address) {
    if (address.startsWith('1')) {
      // P2PKH: OP_DUP OP_HASH160 <20> <hash> OP_EQUALVERIFY OP_CHECKSIG
      final decoded = _base58Decode(address);
      final hash = decoded.sublist(1, 21);
      return Uint8List.fromList(
          [0x76, 0xa9, 0x14, ...hash, 0x88, 0xac]);
    } else if (address.startsWith('3')) {
      // P2SH: OP_HASH160 <20> <hash> OP_EQUAL
      final decoded = _base58Decode(address);
      final hash = decoded.sublist(1, 21);
      return Uint8List.fromList([0xa9, 0x14, ...hash, 0x87]);
    } else if (address.toLowerCase().startsWith('bc1')) {
      // P2WPKH: OP_0 <20> <hash>
      final decoded = _bech32Decode(address);
      if (decoded == null) throw Exception('Invalid bech32 address');
      return Uint8List.fromList([0x00, 0x14, ...decoded]);
    }
    throw Exception('Unsupported address format: $address');
  }

  // ========== Bech32 Encoding/Decoding ==========

  static const _bech32Charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

  int _bech32Polymod(List<int> values) {
    const generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
    int chk = 1;
    for (final v in values) {
      final top = chk >> 25;
      chk = ((chk & 0x1ffffff) << 5) ^ v;
      for (int i = 0; i < 5; i++) {
        if (((top >> i) & 1) == 1) {
          chk ^= generator[i];
        }
      }
    }
    return chk;
  }

  List<int> _bech32HrpExpand(String hrp) {
    final result = <int>[];
    for (final c in hrp.codeUnits) {
      result.add(c >> 5);
    }
    result.add(0);
    for (final c in hrp.codeUnits) {
      result.add(c & 31);
    }
    return result;
  }

  String _bech32Encode(String hrp, List<int> data) {
    final values = _bech32HrpExpand(hrp) + data;
    final polymod =
        _bech32Polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1;
    final checksum = <int>[];
    for (int i = 0; i < 6; i++) {
      checksum.add((polymod >> (5 * (5 - i))) & 31);
    }
    final combined = data + checksum;
    final result = StringBuffer('$hrp' '1');
    for (final c in combined) {
      result.write(_bech32Charset[c]);
    }
    return result.toString();
  }

  Uint8List? _bech32Decode(String address) {
    try {
      final lower = address.toLowerCase();
      final sepIndex = lower.lastIndexOf('1');
      if (sepIndex == -1) return null;

      final hrp = lower.substring(0, sepIndex);
      final dataStr = lower.substring(sepIndex + 1);

      final data = <int>[];
      for (final c in dataStr.split('')) {
        final index = _bech32Charset.indexOf(c);
        if (index == -1) return null;
        data.add(index);
      }

      // Verify checksum
      final values = _bech32HrpExpand(hrp) + data;
      if (_bech32Polymod(values) != 1) return null;

      // Remove checksum (last 6 chars) and witness version (first char)
      final payload = data.sublist(1, data.length - 6);

      // Convert from 5-bit to 8-bit
      final converted = _convertBits(Uint8List.fromList(payload), 5, 8, false);
      return Uint8List.fromList(converted);
    } catch (_) {
      return null;
    }
  }

  bool _validateBech32(String address) {
    final decoded = _bech32Decode(address);
    return decoded != null && decoded.length == 20;
  }

  /// Convert between bit groups
  List<int> _convertBits(Uint8List data, int fromBits, int toBits, bool pad) {
    int acc = 0;
    int bits = 0;
    final result = <int>[];
    final maxV = (1 << toBits) - 1;

    for (final value in data) {
      acc = (acc << fromBits) | value;
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & maxV);
      }
    }

    if (pad) {
      if (bits > 0) {
        result.add((acc << (toBits - bits)) & maxV);
      }
    }

    return result;
  }

  // ========== Utility Methods ==========

  BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  Uint8List _bigIntToBytes(BigInt number) {
    if (number == BigInt.zero) return Uint8List.fromList([0]);
    final bytes = <int>[];
    var n = number;
    while (n > BigInt.zero) {
      bytes.insert(0, (n & BigInt.from(0xff)).toInt());
      n = n >> 8;
    }
    return Uint8List.fromList(bytes);
  }

  Uint8List _uint32LE(int value) {
    return Uint8List(4)
      ..buffer.asByteData().setUint32(0, value, Endian.little);
  }

  Uint8List _uint64LE(BigInt value) {
    final bytes = Uint8List(8);
    var v = value;
    for (int i = 0; i < 8; i++) {
      bytes[i] = (v & BigInt.from(0xff)).toInt();
      v = v >> 8;
    }
    return bytes;
  }

  Uint8List _varint(int value) {
    if (value < 0xfd) {
      return Uint8List.fromList([value]);
    } else if (value <= 0xffff) {
      return Uint8List.fromList([
        0xfd,
        value & 0xff,
        (value >> 8) & 0xff,
      ]);
    } else if (value <= 0xffffffff) {
      return Uint8List.fromList([
        0xfe,
        value & 0xff,
        (value >> 8) & 0xff,
        (value >> 16) & 0xff,
        (value >> 24) & 0xff,
      ]);
    } else {
      throw Exception('Value too large for varint');
    }
  }

  String _hexEncode(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  Uint8List _hexDecode(String hex) {
    final str = hex.startsWith('0x') ? hex.substring(2) : hex;
    final result = Uint8List(str.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(str.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}
