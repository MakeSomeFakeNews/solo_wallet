import 'package:get/get.dart';
import 'wallet_detail_controller.dart';

class WalletDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletDetailController>(() => WalletDetailController());
  }
}
