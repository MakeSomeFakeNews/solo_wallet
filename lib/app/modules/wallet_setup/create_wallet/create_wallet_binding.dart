import 'package:get/get.dart';
import 'create_wallet_controller.dart';

class CreateWalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateWalletController>(() => CreateWalletController());
  }
}
