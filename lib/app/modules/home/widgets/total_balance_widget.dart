import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../home_controller.dart';

class TotalBalanceWidget extends GetView<HomeController> {
  const TotalBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalAssets,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),
              Obx(() => GestureDetector(
                    onTap: controller.toggleHideBalance,
                    child: Icon(
                      controller.hideBalance.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                      size: 22.w,
                    ),
                  )),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() => Text(
                controller.hideBalance.value
                    ? '****'
                    : '\$${controller.totalBalance.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
          SizedBox(height: 4.h),
          Text(
            'USD',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
