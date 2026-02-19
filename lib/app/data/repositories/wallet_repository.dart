import '../../core/models/wallet.dart';
import '../../core/models/account.dart';
import '../../core/services/storage_service.dart';

/// 钱包数据仓库 - 持久化操作封装
class WalletRepository {
  /// 读取本地钱包
  Wallet? loadWallet() {
    final data = StorageService.getWalletData();
    if (data == null) return null;
    return Wallet.fromJson(data);
  }

  /// 保存钱包
  Future<void> saveWallet(Wallet wallet) async {
    await StorageService.saveWalletData(wallet.toJson());
  }

  /// 检查是否存在钱包
  bool get hasWallet => StorageService.hasWallet;

  /// 更新特定账户
  Future<void> updateAccount(Account account) async {
    final wallet = loadWallet();
    if (wallet == null) return;

    final accounts = wallet.accounts.map((a) {
      return a.coinId == account.coinId ? account : a;
    }).toList();

    await saveWallet(wallet.copyWith(accounts: accounts));
  }

  /// 添加账户
  Future<void> addAccount(Account account) async {
    final wallet = loadWallet();
    if (wallet == null) return;

    final existing = wallet.accounts.indexWhere(
      (a) => a.coinId == account.coinId,
    );
    final List<Account> accounts = List.from(wallet.accounts);
    if (existing >= 0) {
      accounts[existing] = account;
    } else {
      accounts.add(account);
    }

    await saveWallet(wallet.copyWith(accounts: accounts));
  }

  /// 更新激活的币种列表
  Future<void> updateActiveCoins(List<String> coinIds) async {
    final wallet = loadWallet();
    if (wallet == null) return;
    await saveWallet(wallet.copyWith(activeCoins: coinIds));
  }

  /// 删除钱包（完全重置）
  Future<void> deleteWallet() async {
    await StorageService.clearAll();
  }
}
