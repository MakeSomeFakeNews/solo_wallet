import 'package:get/get.dart';
import 'export_key_controller.dart';

class ExportKeyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExportKeyController>(() => ExportKeyController());
  }
}
