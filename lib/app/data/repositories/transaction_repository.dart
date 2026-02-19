import 'package:get/get.dart';
import '../../core/models/transaction.dart';
import '../../core/services/storage_service.dart';

/// 交易记录仓库 - 管理本地交易历史
class TransactionRepository extends GetxService {
  /// 获取指定币种的交易列表（倒序）
  List<Transaction> getTransactions(String coinId) {
    final rawList = StorageService.getTransactions(coinId);
    final txList = rawList.map((j) => Transaction.fromJson(j)).toList();
    txList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return txList;
  }

  /// 获取所有币种的交易（按时间倒序）
  List<Transaction> getAllTransactions(List<String> coinIds) {
    final allTx = <Transaction>[];
    for (final coinId in coinIds) {
      allTx.addAll(getTransactions(coinId));
    }
    allTx.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allTx;
  }

  /// 保存交易记录（新增或更新）
  Future<void> saveTransaction(Transaction tx) async {
    final existing = getTransactions(tx.coinId);
    final idx = existing.indexWhere((t) => t.id == tx.id);
    if (idx >= 0) {
      existing[idx] = tx;
    } else {
      existing.insert(0, tx);
    }
    await StorageService.saveTransactions(
      tx.coinId,
      existing.map((t) => t.toJson()).toList(),
    );
  }

  /// 更新交易状态（如广播后获得txHash）
  Future<void> updateTransaction(Transaction updated) async {
    await saveTransaction(updated);
  }

  /// 按txHash查找
  Transaction? findByHash(String coinId, String txHash) {
    final list = getTransactions(coinId);
    try {
      return list.firstWhere((t) => t.txHash == txHash);
    } catch (_) {
      return null;
    }
  }

  /// 按ID查找
  Transaction? findById(String coinId, String id) {
    final list = getTransactions(coinId);
    try {
      return list.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 删除交易记录
  Future<void> deleteTransaction(String coinId, String id) async {
    final list = getTransactions(coinId);
    list.removeWhere((t) => t.id == id);
    await StorageService.saveTransactions(
      coinId,
      list.map((t) => t.toJson()).toList(),
    );
  }

  /// 获取待广播的交易
  List<Transaction> getPendingTransactions(List<String> coinIds) {
    return getAllTransactions(coinIds)
        .where((t) => t.status == TransactionStatus.pending ||
                      t.status == TransactionStatus.broadcasting)
        .toList();
  }
}
