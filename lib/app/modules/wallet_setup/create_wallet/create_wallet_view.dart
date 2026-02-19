import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import 'create_wallet_controller.dart';

class CreateWalletView extends GetView<CreateWalletController> {
  const CreateWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppStrings.appTagline,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),

              // Create wallet card
              _WalletOptionCard(
                icon: Icons.add_circle_outline,
                title: AppStrings.createWallet,
                description: AppStrings.createWalletDesc,
                onTap: () => _showLengthSelection(context),
              ),

              SizedBox(height: 16.h),

              // Import wallet card
              _WalletOptionCard(
                icon: Icons.download_outlined,
                title: AppStrings.importWallet,
                description: AppStrings.importWalletDesc,
                onTap: () => Get.toNamed(AppRoutes.importWallet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLengthSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectMnemonicLength,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            _LengthOption(
              title: AppStrings.mnemonic12,
              isSelected: true,
              onTap: () {
                controller.selectLength(12);
                Navigator.pop(context);
                controller.goToShowMnemonic();
              },
            ),
            SizedBox(height: 12.h),
            _LengthOption(
              title: AppStrings.mnemonic24,
              isSelected: false,
              onTap: () {
                controller.selectLength(24);
                Navigator.pop(context);
                controller.goToShowMnemonic();
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _WalletOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _WalletOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.darkDivider),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _LengthOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LengthOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.darkCardSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.darkDivider,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
