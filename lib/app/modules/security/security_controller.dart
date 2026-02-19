import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/services/security_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/pin_verify_dialog.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class SecurityController extends GetxController {
  final SecurityService securityService = Get.find();

  final RxBool antiScreenshot = false.obs;
  final RxBool clipboardMonitor = false.obs;

  @override
  void onInit() {
    super.onInit();
    antiScreenshot.value = StorageService.antiScreenshot;
    clipboardMonitor.value = StorageService.clipboardMonitor;
  }

  Future<void> toggleAntiScreenshot(bool value) async {
    await StorageService.setAntiScreenshot(value);
    antiScreenshot.value = value;
    await securityService.setScreenProtection(value);
  }

  Future<void> toggleClipboardMonitor(bool value) async {
    await StorageService.setClipboardMonitor(value);
    clipboardMonitor.value = value;
  }

  void navigateToBackupVerify() {
    Get.toNamed(AppRoutes.backupVerify);
  }

  Future<void> navigateToExportKey() async {
    final verified = await PinVerifyDialog.show();
    if (verified) {
      Get.toNamed(AppRoutes.exportKey);
    }
  }

  Future<void> viewMnemonic() async {
    final verified = await PinVerifyDialog.show();
    if (!verified) return;

    final mnemonic = await StorageService.getMnemonic();
    if (mnemonic == null || mnemonic.isEmpty) {
      Get.snackbar(AppStrings.error, '未找到助记词');
      return;
    }

    Get.dialog(_MnemonicDialog(mnemonic: mnemonic));
  }
}

class _MnemonicDialog extends StatelessWidget {
  final String mnemonic;

  const _MnemonicDialog({required this.mnemonic});

  @override
  Widget build(BuildContext context) {
    final words = mnemonic.split(' ');
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(25),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppStrings.mnemonicWarning,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              AppStrings.viewMnemonic,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),

            // Words Grid
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(words.length, (index) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkCardSecondary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${index + 1}. ${words[index]}',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: Text(AppStrings.close, style: TextStyle(fontSize: 15.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
