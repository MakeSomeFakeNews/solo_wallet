import 'package:get/get.dart';
import '../models/wallet.dart';
import '../models/account.dart';
import 'storage_service.dart';

/// 钱包核心服务 - 管理钱包生命周期
/// 注意：加密操作由 crypto 层完成，本服务负责数据管理
class WalletService extends GetxService {
  final Rx<Wallet?> currentWallet = Rx<Wallet?>(null);
  final RxList<String> activeCoins = <String>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWallet();
  }

  /// 检查钱包是否存在
  bool get hasWallet => StorageService.hasWallet;

  /// 是否观察模式
  bool get isWatchOnly => currentWallet.value?.isWatchOnly ?? false;

  void _loadWallet() {
    final data = StorageService.getWalletData();
    if (data != null) {
      currentWallet.value = Wallet.fromJson(data);
      activeCoins.value = List<String>.from(currentWallet.value?.activeCoins ?? []);
    }
  }

  /// 保存钱包到本地存储
  Future<void> _saveWallet(Wallet wallet) async {
    await StorageService.saveWalletData(wallet.toJson());
    currentWallet.value = wallet;
    activeCoins.value = List<String>.from(wallet.activeCoins);
  }

  /// 创建新HD钱包
  Future<void> createWallet({
    required String mnemonic,
    required List<Account> initialAccounts,
    String name = 'My Wallet',
    List<String> defaultActiveCoins = const ['btc', 'eth', 'trx'],
  }) async {
    isLoading.value = true;
    try {
      await StorageService.saveMnemonic(mnemonic);

      final wallet = Wallet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: WalletType.hd,
        createdAt: DateTime.now(),
        accounts: initialAccounts,
        activeCoins: defaultActiveCoins,
      );
      await _saveWallet(wallet);
    } finally {
      isLoading.value = false;
    }
  }

  /// 从助记词导入钱包
  Future<void> importWalletFromMnemonic({
    required String mnemonic,
    required List<Account> accounts,
    String name = 'Imported Wallet',
    List<String> defaultActiveCoins = const ['btc', 'eth', 'trx'],
  }) async {
    isLoading.value = true;
    try {
      await StorageService.saveMnemonic(mnemonic);

      final wallet = Wallet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: WalletType.hd,
        createdAt: DateTime.now(),
        accounts: accounts,
        activeCoins: defaultActiveCoins,
      );
      await _saveWallet(wallet);
    } finally {
      isLoading.value = false;
    }
  }

  /// 从私钥导入单币种钱包
  Future<void> importWalletFromPrivateKey({
    required String coinId,
    required Account account,
    String name = 'Private Key Wallet',
  }) async {
    isLoading.value = true;
    try {
      final wallet = Wallet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: WalletType.privateKey,
        createdAt: DateTime.now(),
        accounts: [account],
        activeCoins: [coinId],
      );
      await _saveWallet(wallet);
    } finally {
      isLoading.value = false;
    }
  }

  /// 导入观察钱包（扩展公钥）
  Future<void> importWatchOnlyWallet({
    required List<Account> accounts,
    String name = 'Watch Only Wallet',
  }) async {
    isLoading.value = true;
    try {
      final wallet = Wallet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: WalletType.watchOnly,
        createdAt: DateTime.now(),
        accounts: accounts,
        activeCoins: accounts.map((a) => a.coinId).toList(),
      );
      await _saveWallet(wallet);
    } finally {
      isLoading.value = false;
    }
  }

  /// 激活币种
  Future<void> activateCoin(String coinId) async {
    final wallet = currentWallet.value;
    if (wallet == null) return;
    if (wallet.activeCoins.contains(coinId)) return;

    final updated = wallet.copyWith(
      activeCoins: [...wallet.activeCoins, coinId],
    );
    await _saveWallet(updated);
  }

  /// 停用币种
  Future<void> deactivateCoin(String coinId) async {
    final wallet = currentWallet.value;
    if (wallet == null) return;

    final updated = wallet.copyWith(
      activeCoins: wallet.activeCoins.where((c) => c != coinId).toList(),
    );
    await _saveWallet(updated);
  }

  /// 更新账户地址（生成新地址时）
  Future<void> updateAccount(Account updatedAccount) async {
    final wallet = currentWallet.value;
    if (wallet == null) return;

    final accounts = wallet.accounts.map((a) {
      return a.coinId == updatedAccount.coinId ? updatedAccount : a;
    }).toList();

    final updated = wallet.copyWith(accounts: accounts);
    await _saveWallet(updated);
  }

  /// 添加账户（首次激活新币种时）
  Future<void> addAccount(Account account) async {
    final wallet = currentWallet.value;
    if (wallet == null) return;

    // 如果已存在则替换
    final existing = wallet.accounts.indexWhere(
      (a) => a.coinId == account.coinId,
    );
    final List<Account> accounts = List.from(wallet.accounts);
    if (existing >= 0) {
      accounts[existing] = account;
    } else {
      accounts.add(account);
    }

    final updated = wallet.copyWith(accounts: accounts);
    await _saveWallet(updated);
  }

  /// 重命名钱包
  Future<void> renameWallet(String newName) async {
    final wallet = currentWallet.value;
    if (wallet == null) return;
    final updated = wallet.copyWith(name: newName);
    await _saveWallet(updated);
  }

  /// 获取指定币种账户
  Account? getAccount(String coinId) {
    return currentWallet.value?.getAccount(coinId);
  }

  /// 获取指定币种地址
  String? getAddress(String coinId) {
    return currentWallet.value?.getAddress(coinId);
  }

  /// 删除钱包（重置）
  Future<void> deleteWallet() async {
    await StorageService.clearAll();
    currentWallet.value = null;
    activeCoins.clear();
  }
}
