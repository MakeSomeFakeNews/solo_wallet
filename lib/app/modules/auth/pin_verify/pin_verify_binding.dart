import 'package:get/get.dart';
import 'pin_verify_controller.dart';

class PinVerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PinVerifyController>(() => PinVerifyController());
  }
}
