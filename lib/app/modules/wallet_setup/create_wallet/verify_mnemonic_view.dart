import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../theme/app_colors.dart';
import 'create_wallet_controller.dart';

class VerifyMnemonicView extends GetView<CreateWalletController> {
  const VerifyMnemonicView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.verifyMnemonic,
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // Instruction
              Obx(() => Text(
                    '请依次选择第 ${controller.verificationIndices.map((i) => i + 1).join("、")} 个词',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  )),

              SizedBox(height: 24.h),

              // Selected word slots
              Obx(() => Row(
                    children: List.generate(4, (index) {
                      final hasWord = index < controller.selectedWords.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: hasWord
                              ? () => controller.removeSelectedWord(index)
                              : null,
                          child: Container(
                            height: 44.h,
                            margin: EdgeInsets.only(right: index < 3 ? 8.w : 0),
                            decoration: BoxDecoration(
                              color: hasWord
                                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                                  : AppColors.darkCardSecondary,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: hasWord
                                    ? AppColors.primaryBlue
                                    : AppColors.darkDivider,
                              ),
                            ),
                            child: Center(
                              child: hasWord
                                  ? Text(
                                      controller.selectedWords[index],
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(
                                      '#${controller.verificationIndices.length > index ? controller.verificationIndices[index] + 1 : ''}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                  )),

              SizedBox(height: 12.h),

              // Error message
              Obx(() => controller.verificationError.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        controller.verificationError.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.error,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),

              SizedBox(height: 8.h),

              // Word options (shuffled)
              Expanded(
                child: Obx(() => Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: controller.shuffledWords
                          .map((word) => GestureDetector(
                                onTap: () => controller.selectWord(word),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCard,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: AppColors.darkDivider,
                                    ),
                                  ),
                                  child: Text(
                                    word,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    )),
              ),

              // Reset button
              Obx(() => controller.verificationError.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed: controller.resetVerification,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            '重新选择',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(height: 24.h)),
            ],
          ),
        ),
      ),
    );
  }
}
