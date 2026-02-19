import 'package:get/get.dart';
import '../../../core/services/security_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/values/app_constants.dart';
import '../../../routes/app_routes.dart';

class PinVerifyController extends GetxController {
  final pinInput = ''.obs;
  final error = ''.obs;
  final isLoading = false.obs;

  final _securityService = Get.find<SecurityService>();

  bool get biometricEnabled => StorageService.biometricEnabled;

  @override
  void onInit() {
    super.onInit();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (!biometricEnabled) return;
    final success = await _securityService.authenticateWithBiometrics();
    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void onNumberPressed(int number) {
    if (pinInput.value.length < AppConstants.pinLength) {
      pinInput.value += number.toString();
      if (pinInput.value.length == AppConstants.pinLength) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _verifyPin();
        });
      }
    }
  }

  void onDeletePressed() {
    if (pinInput.value.isNotEmpty) {
      pinInput.value = pinInput.value.substring(0, pinInput.value.length - 1);
    }
    error.value = '';
  }

  Future<void> _verifyPin() async {
    isLoading.value = true;
    final success = await _securityService.verifyPin(pinInput.value);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      if (_securityService.lockoutUntil != null) {
        error.value = '尝试次数过多，请稍后再试';
      } else {
        error.value =
            'PIN码错误，还剩${_securityService.remainingAttempts}次机会';
      }
      pinInput.value = '';
    }
  }

  Future<void> onBiometricPressed() async {
    final success = await _securityService.authenticateWithBiometrics();
    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
