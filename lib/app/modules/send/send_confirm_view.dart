import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/app_button.dart';
import 'send_controller.dart';

class SendConfirmView extends GetView<SendController> {
  const SendConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final toAddress = args['toAddress'] ?? '';
    final amount = args['amount'] ?? '0';
    final fee = args['fee'] ?? '--';
    final fromAddress = controller.walletService.getAddress(controller.coinId) ??
        '未知地址';

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
            AppStrings.reviewTransaction,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount
                        Center(
                          child: Column(
                            children: [
                              Text(
                                AppStrings.amount,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '$amount ${controller.coinInfo.symbol}',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Divider(color: AppColors.darkDivider),
                        SizedBox(height: 16.h),

                        // From
                        _buildInfoRow(
                          AppStrings.fromAddress,
                          fromAddress,
                          isAddress: true,
                        ),
                        SizedBox(height: 16.h),

                        // To
                        _buildInfoRow(
                          AppStrings.toAddress,
                          toAddress,
                          isAddress: true,
                        ),
                        SizedBox(height: 16.h),

                        // Fee
                        _buildInfoRow(AppStrings.transactionFee, fee),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Sign button
              AppButton(
                text: AppStrings.signOffline,
                onPressed: controller.signTransaction,
                icon: Icons.edit_note,
              ),
              SizedBox(height: 8.h),
              Text(
                '签名将在本地完成，不需要网络连接',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textHint,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: isAddress ? 13.sp : 15.sp,
            color: AppColors.textPrimary,
            fontFamily: isAddress ? 'monospace' : null,
          ),
        ),
      ],
    );
  }
}
