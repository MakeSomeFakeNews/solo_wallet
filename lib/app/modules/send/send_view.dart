import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../core/values/app_strings.dart' as strings;
import '../../core/widgets/app_button.dart';
import 'send_controller.dart';

class SendView extends GetView<SendController> {
  const SendView({super.key});

  @override
  Widget build(BuildContext context) {
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
            '${strings.AppStrings.send} ${controller.coinInfo.symbol}',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient address
              _buildLabel(strings.AppStrings.enterAddress),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.addressController,
                onChanged: controller.onAddressChanged,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: strings.AppStrings.enterAddress,
                  hintStyle: TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.primaryBlue,
                      size: 24.w,
                    ),
                    onPressed: controller.scanQrCode,
                  ),
                ),
              ),
              Obx(() {
                if (controller.addressError.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    controller.addressError.value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.error,
                    ),
                  ),
                );
              }),
              SizedBox(height: 20.h),

              // Amount
              _buildLabel(strings.AppStrings.enterAmount),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: '0.0',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: TextButton(
                    onPressed: controller.setMaxAmount,
                    child: Text(
                      'MAX',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Available balance
              Obx(() => Row(
                    children: [
                      Text(
                        '${strings.AppStrings.availableBalance}: ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textHint,
                        ),
                      ),
                      Text(
                        '${controller.availableBalance.value} ${controller.coinInfo.symbol}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 20.h),

              // Advanced options
              Obx(() => Column(
                    children: [
                      GestureDetector(
                        onTap: () => controller.showAdvancedOptions.value =
                            !controller.showAdvancedOptions.value,
                        child: Row(
                          children: [
                            Text(
                              strings.AppStrings.advancedOptions,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              controller.showAdvancedOptions.value
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
                              size: 20.w,
                            ),
                          ],
                        ),
                      ),
                      if (controller.showAdvancedOptions.value) ...[
                        SizedBox(height: 12.h),
                        _buildAdvancedOptions(),
                      ],
                    ],
                  )),
              SizedBox(height: 20.h),

              // Fee estimate
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.AppStrings.transactionFee,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Obx(() => Text(
                          controller.estimatedFee,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Preview button
              AppButton(
                text: strings.AppStrings.reviewTransaction,
                onPressed: controller.proceedToConfirm,
                icon: Icons.preview,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    if (controller.coinId == 'btc') {
      return _buildBtcAdvanced();
    } else {
      return _buildEthAdvanced();
    }
  }

  Widget _buildBtcAdvanced() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildAdvancedField(
            label: strings.AppStrings.btcFeeRate,
            value: controller.feeRate.value.toString(),
            onChanged: (v) {
              final val = int.tryParse(v);
              if (val != null) controller.feeRate.value = val;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEthAdvanced() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildAdvancedField(
            label: strings.AppStrings.gasPrice,
            value: controller.gasPrice.value.toString(),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) controller.gasPrice.value = val;
            },
          ),
          SizedBox(height: 12.h),
          _buildAdvancedField(
            label: strings.AppStrings.gasLimit,
            value: controller.gasLimit.value.toString(),
            onChanged: (v) {
              final val = int.tryParse(v);
              if (val != null) controller.gasLimit.value = val;
            },
          ),
          SizedBox(height: 12.h),
          _buildAdvancedField(
            label: strings.AppStrings.nonce,
            value: controller.nonce.value.toString(),
            onChanged: (v) {
              final val = int.tryParse(v);
              if (val != null) controller.nonce.value = val;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: TextEditingController(text: value),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.darkBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
