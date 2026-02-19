import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/wallet_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final onboardingComplete = StorageService.onboardingComplete;
    if (!onboardingComplete) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final walletService = Get.find<WalletService>();
    if (walletService.hasWallet) {
      Get.offAllNamed(AppRoutes.pinVerify);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
