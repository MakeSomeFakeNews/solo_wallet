import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../core/services/storage_service.dart';

/// 可选网络数据提供者（仅在用户主动触发时使用）
/// 用于查询余额、广播交易、获取Gas价格等
class NetworkProvider extends GetxService {
  late Dio _dio;

  // 默认公共节点
  static const _defaultNodes = {
    'eth': 'https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
    'bsc': 'https://bsc-dataseed1.binance.org',
    'trx': 'https://api.trongrid.io',
    'btc': 'https://blockstream.info/api',
  };

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  /// 获取当前链的RPC端点
  String _getNode(String chainId) {
    final custom = StorageService.networkNodes;
    return custom[chainId] ?? _defaultNodes[chainId] ?? '';
  }

  /// ETH JSON-RPC 调用
  Future<dynamic> ethRpc(String method, List<dynamic> params) async {
    final url = _getNode('eth');
    if (url.isEmpty) throw Exception('ETH节点未配置');
    final response = await _dio.post(url, data: {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': 1,
    });
    final result = response.data as Map<String, dynamic>;
    if (result.containsKey('error')) {
      throw Exception(result['error']['message']);
    }
    return result['result'];
  }

  /// 获取ETH账户nonce
  Future<int> getEthNonce(String address) async {
    final result = await ethRpc('eth_getTransactionCount', [address, 'latest']);
    return int.parse((result as String).substring(2), radix: 16);
  }

  /// 获取ETH Gas价格（Wei）
  Future<BigInt> getEthGasPrice() async {
    final result = await ethRpc('eth_gasPrice', []);
    return BigInt.parse((result as String).substring(2), radix: 16);
  }

  /// 广播ETH/BSC已签名交易
  Future<String> broadcastEthTransaction(String rawTxHex) async {
    return await ethRpc('eth_sendRawTransaction', [rawTxHex]) as String;
  }

  /// BSC JSON-RPC 调用
  Future<dynamic> bscRpc(String method, List<dynamic> params) async {
    final url = _getNode('bsc');
    if (url.isEmpty) throw Exception('BSC节点未配置');
    final response = await _dio.post(url, data: {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': 1,
    });
    final result = response.data as Map<String, dynamic>;
    if (result.containsKey('error')) {
      throw Exception(result['error']['message']);
    }
    return result['result'];
  }

  /// 广播BTC交易（使用Blockstream API）
  Future<String> broadcastBtcTransaction(String rawTxHex) async {
    final url = '${_getNode('btc')}/tx';
    final response = await _dio.post(url, data: rawTxHex);
    return response.data as String; // txHash
  }

  /// 广播TRX交易
  Future<Map<String, dynamic>> broadcastTrxTransaction(
    Map<String, dynamic> signedTx,
  ) async {
    final url = '${_getNode('trx')}/wallet/broadcasttransaction';
    final response = await _dio.post(url, data: signedTx);
    return response.data as Map<String, dynamic>;
  }

  /// 获取ETH账户余额（Wei）
  Future<BigInt> getEthBalance(String address) async {
    final result = await ethRpc('eth_getBalance', [address, 'latest']);
    return BigInt.parse((result as String).substring(2), radix: 16);
  }

  /// 获取ERC20代币余额
  Future<BigInt> getErc20Balance(String tokenAddress, String ownerAddress) async {
    // balanceOf(address) = 0x70a08231 + padded address
    final paddedAddr = ownerAddress.replaceFirst('0x', '').padLeft(64, '0');
    final data = '0x70a08231$paddedAddr';
    final result = await ethRpc('eth_call', [
      {'to': tokenAddress, 'data': data},
      'latest',
    ]);
    return BigInt.parse((result as String).substring(2), radix: 16);
  }
}
