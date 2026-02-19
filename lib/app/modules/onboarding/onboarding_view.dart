import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/values/app_strings.dart';
import '../../theme/app_colors.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Obx(() => controller.currentPage.value < 2
                  ? TextButton(
                      onPressed: controller.skipOnboarding,
                      child: Text(
                        '跳过',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : SizedBox(height: 48.h)),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: const [
                  _OnboardingPage(
                    icon: Icons.lock_outline,
                    title: AppStrings.onboardingTitle1,
                    description: AppStrings.onboardingDesc1,
                  ),
                  _OnboardingPage(
                    icon: Icons.account_balance_wallet_outlined,
                    title: AppStrings.onboardingTitle2,
                    description: AppStrings.onboardingDesc2,
                  ),
                  _OnboardingPage(
                    icon: Icons.qr_code_scanner,
                    title: AppStrings.onboardingTitle3,
                    description: AppStrings.onboardingDesc3,
                  ),
                ],
              ),
            ),

            // Page indicator
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: controller.currentPage.value == index ? 24.w : 8.w,
                      height: 8.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: controller.currentPage.value == index
                            ? AppColors.primaryBlue
                            : AppColors.darkDivider,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                )),

            SizedBox(height: 32.h),

            // Bottom button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        controller.currentPage.value < 2
                            ? AppStrings.next
                            : '开始',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56.sp,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
