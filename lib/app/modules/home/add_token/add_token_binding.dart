import 'package:get/get.dart';

import 'add_token_controller.dart';

class AddTokenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTokenController>(() => AddTokenController());
  }
}
