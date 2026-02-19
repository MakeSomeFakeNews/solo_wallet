import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/values/app_strings.dart';
import '../../../theme/app_colors.dart';
import 'pin_verify_controller.dart';

class PinVerifyView extends GetView<PinVerifyController> {
  const PinVerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60.h),

            // App icon
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                size: 32.sp,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              AppStrings.enterPin,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 40.h),

            // PIN dots
            Obx(() => _PinDots(
                  filledCount: controller.pinInput.value.length,
                  total: AppConstants.pinLength,
                )),

            SizedBox(height: 16.h),

            // Error
            Obx(() => controller.error.isNotEmpty
                ? Text(
                    controller.error.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.error,
                    ),
                  )
                : SizedBox(height: 18.h)),

            const Spacer(),

            // Number pad
            _NumberPad(
              onNumberPressed: controller.onNumberPressed,
              onDeletePressed: controller.onDeletePressed,
              showBiometric: controller.biometricEnabled,
              onBiometricPressed: controller.onBiometricPressed,
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int filledCount;
  final int total;

  const _PinDots({
    required this.filledCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isFilled = index < filledCount;
        return Container(
          width: 14.w,
          height: 14.w,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.white : Colors.transparent,
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final Function(int) onNumberPressed;
  final VoidCallback onDeletePressed;
  final bool showBiometric;
  final VoidCallback onBiometricPressed;

  const _NumberPad({
    required this.onNumberPressed,
    required this.onDeletePressed,
    required this.showBiometric,
    required this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NumberKey(number: 1, onTap: () => onNumberPressed(1)),
              _NumberKey(number: 2, onTap: () => onNumberPressed(2)),
              _NumberKey(number: 3, onTap: () => onNumberPressed(3)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NumberKey(number: 4, onTap: () => onNumberPressed(4)),
              _NumberKey(number: 5, onTap: () => onNumberPressed(5)),
              _NumberKey(number: 6, onTap: () => onNumberPressed(6)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NumberKey(number: 7, onTap: () => onNumberPressed(7)),
              _NumberKey(number: 8, onTap: () => onNumberPressed(8)),
              _NumberKey(number: 9, onTap: () => onNumberPressed(9)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Biometric button or empty space
              SizedBox(
                width: 72.w,
                height: 56.h,
                child: showBiometric
                    ? IconButton(
                        onPressed: onBiometricPressed,
                        icon: Icon(
                          Icons.fingerprint,
                          color: AppColors.primaryBlue,
                          size: 28.sp,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              _NumberKey(number: 0, onTap: () => onNumberPressed(0)),
              SizedBox(
                width: 72.w,
                height: 56.h,
                child: IconButton(
                  onPressed: onDeletePressed,
                  icon: Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textPrimary,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberKey extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _NumberKey({
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
