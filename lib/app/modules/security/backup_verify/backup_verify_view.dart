import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../theme/app_colors.dart';
import 'backup_verify_controller.dart';

class BackupVerifyView extends GetView<BackupVerifyController> {
  const BackupVerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.backupVerification),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.isVerified.value) {
          return _buildSuccessView();
        }
        return _buildQuizView();
      }),
    );
  }

  Widget _buildQuizView() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '请依次点击以下位置的助记词',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
                '需要验证的位置: ${controller.quizIndices.map((i) => '第${i + 1}个').join(', ')}',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              )),
          SizedBox(height: 24.h),

          // Answer Slots
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final word = controller.selectedWords[index];
                  final position = controller.quizIndices.isNotEmpty
                      ? controller.quizIndices[index] + 1
                      : 0;
                  return GestureDetector(
                    onTap: () => controller.onSlotTapped(index),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 75.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: word != null
                            ? AppColors.primaryBlue.withAlpha(51)
                            : AppColors.darkCardSecondary,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: word != null
                              ? AppColors.primaryBlue
                              : AppColors.darkDivider,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '#$position',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textHint,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            word ?? '',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )),
          SizedBox(height: 32.h),

          // Word Buttons Grid
          Text(
            '点击选择:',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
          ),
          SizedBox(height: 8.h),
          Obx(() => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: controller.shuffledWords.map((word) {
                  final isSelected = controller.selectedWords.contains(word);
                  return GestureDetector(
                    onTap: isSelected ? null : () => controller.onWordTapped(word),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.darkDivider
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.darkDivider
                              : AppColors.primaryBlue.withAlpha(76),
                        ),
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

          const Spacer(),

          // Verify Button
          Obx(() {
            final allFilled = !controller.selectedWords.contains(null);
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: allFilled ? _onVerify : null,
                child: Text(AppStrings.confirm, style: TextStyle(fontSize: 15.sp)),
              ),
            );
          }),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  void _onVerify() {
    final result = controller.verifyResult();
    if (!result) {
      Get.snackbar(
        AppStrings.error,
        '验证失败，请重试',
        snackPosition: SnackPosition.BOTTOM,
      );
      controller.retry();
    }
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80.sp,
              color: AppColors.success,
            ),
            SizedBox(height: 24.h),
            Text(
              '备份验证成功',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Text(
              '您的助记词备份正确，请妥善保管。',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: Text(AppStrings.done, style: TextStyle(fontSize: 15.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
