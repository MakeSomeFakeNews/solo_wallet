import 'package:get/get.dart';
import 'node_settings_controller.dart';

class NodeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NodeSettingsController>(() => NodeSettingsController());
  }
}
