import 'package:get/get.dart';

import '../../core/crypto/coins/coin_registry.dart';
import '../../core/models/coin_info.dart';
import '../../core/models/transaction.dart';
import '../../core/services/wallet_service.dart';

class HistoryController extends GetxController {
  final WalletService walletService = Get.find();

  final RxString selectedCoinId = ''.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    // Mock transactions for now
    final mockTxs = <Transaction>[
      Transaction(
        id: 'tx_001',
        coinId: 'btc',
        txHash: '3a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b',
        fromAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        toAddress: '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
        amount: BigInt.from(5000000),
        fee: BigInt.from(10000),
        status: TransactionStatus.confirmed,
        direction: TransactionDirection.outgoing,
        confirmations: 6,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        confirmedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Transaction(
        id: 'tx_002',
        coinId: 'eth',
        txHash: '0xabc123def456789abc123def456789abc123def456789abc123def456789abcd',
        fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
        toAddress: '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18',
        amount: BigInt.parse('500000000000000000'),
        fee: BigInt.parse('21000000000000'),
        status: TransactionStatus.confirmed,
        direction: TransactionDirection.incoming,
        confirmations: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        confirmedAt: DateTime.now().subtract(const Duration(hours: 23)),
      ),
      Transaction(
        id: 'tx_003',
        coinId: 'btc',
        txHash: null,
        fromAddress: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        toAddress: '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
        amount: BigInt.from(1000000),
        fee: BigInt.from(5000),
        status: TransactionStatus.pending,
        direction: TransactionDirection.outgoing,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        rawTx: 'f86c808504a817c8008252089...',
      ),
    ];

    transactions.value = mockTxs;
    _applyFilter();
  }

  void filterByCoin(String? coinId) {
    selectedCoinId.value = coinId ?? '';
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedCoinId.value.isEmpty) {
      filteredTransactions.value = transactions;
    } else {
      filteredTransactions.value = transactions
          .where((tx) => tx.coinId == selectedCoinId.value)
          .toList();
    }
  }

  CoinInfo? getCoinInfo(String coinId) => CoinRegistry.getById(coinId);

  String formatTxAmount(Transaction tx) {
    final coin = getCoinInfo(tx.coinId);
    if (coin == null) return tx.amount.toString();
    return '${tx.direction == TransactionDirection.outgoing ? "-" : "+"}'
        '${coin.formatAmount(tx.amount)} ${coin.symbol}';
  }

  String formatTxTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
    }
  }

  String shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  void importTransactionRecord() {
    // TODO: Open QR scanner to import tx record
    Get.snackbar('提示', '导入功能开发中', snackPosition: SnackPosition.BOTTOM);
  }
}
