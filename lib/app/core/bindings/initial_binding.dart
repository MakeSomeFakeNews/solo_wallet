import 'package:get/get.dart';
import '../services/security_service.dart';
import '../services/wallet_service.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/providers/network_provider.dart';

/// 应用启动时的全局依赖注入
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 核心服务（永久存在）
    Get.put(SecurityService(), permanent: true);
    Get.put(WalletService(), permanent: true);
    // 数据仓库
    Get.put(WalletRepository(), permanent: true);
    Get.put(TransactionRepository(), permanent: true);
    // 网络（懒加载，用户主动触发时才初始化）
    Get.lazyPut(() => NetworkProvider(), fenix: true);
  }
}
