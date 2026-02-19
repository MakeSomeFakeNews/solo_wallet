import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/app_button.dart';

class SignedTxView extends StatelessWidget {
  const SignedTxView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final signedTx = args['signedTx'] as String? ?? '';

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          title: Text(
            AppStrings.signedTransaction,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // QR code
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: QrImageView(
                  data: signedTx,
                  version: QrVersions.auto,
                  size: 200.w,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Broadcast reminder
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        AppStrings.broadcastReminder,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Signed transaction hex
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 160.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    signedTx,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Copy button
              AppButton(
                text: AppStrings.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: signedTx));
                  Get.snackbar(
                    '已复制',
                    '已签名交易已复制到剪贴板',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: Icons.copy,
              ),
              SizedBox(height: 12.h),

              // Share button
              AppButton(
                text: AppStrings.share,
                onPressed: () {
                  Share.share(signedTx, subject: '已签名交易');
                },
                isOutlined: true,
                icon: Icons.share,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
