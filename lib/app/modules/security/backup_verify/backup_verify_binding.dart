import 'package:get/get.dart';
import 'backup_verify_controller.dart';

class BackupVerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BackupVerifyController>(() => BackupVerifyController());
  }
}
