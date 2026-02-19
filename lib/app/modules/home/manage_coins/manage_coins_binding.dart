import 'package:get/get.dart';

import 'manage_coins_controller.dart';

class ManageCoinsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageCoinsController>(() => ManageCoinsController());
  }
}
