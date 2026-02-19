import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../theme/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/models/coin_info.dart';
import '../../core/widgets/app_button.dart';
import 'receive_controller.dart';

class ReceiveView extends GetView<ReceiveController> {
  const ReceiveView({super.key});

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
            '${AppStrings.receive} ${controller.coinInfo.symbol}',
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
              SizedBox(height: 16.h),
              // Description
              Text(
                AppStrings.receiveDesc,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // QR Code
              Obx(() => Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: QrImageView(
                      data: controller.currentAddress.value,
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
                  )),
              SizedBox(height: 24.h),

              // Address type selector (BTC only)
              Obx(() {
                if (controller.supportedTypes.length <= 1) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.addressType,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: controller.supportedTypes.map((type) {
                        final isSelected =
                            controller.currentAddressType.value == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.selectAddressType(type),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.darkCard,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Text(
                                  _addressTypeShortLabel(type),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),
                  ],
                );
              }),

              // Address display
              Obx(() => Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.currentAddress.value,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: controller.copyAddress,
                          child: Icon(
                            Icons.copy,
                            color: AppColors.primaryBlue,
                            size: 20.w,
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 24.h),

              // Copy address button
              AppButton(
                text: AppStrings.copyAddress,
                onPressed: controller.copyAddress,
                icon: Icons.copy,
              ),
              SizedBox(height: 12.h),

              // Generate new address button
              AppButton(
                text: AppStrings.generateNewAddress,
                onPressed: controller.generateNewAddress,
                isOutlined: true,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _addressTypeShortLabel(AddressType type) {
    switch (type) {
      case AddressType.legacy:
        return 'Legacy';
      case AddressType.segwit:
        return 'SegWit';
      case AddressType.nativeSegwit:
        return 'Bech32';
      case AddressType.standard:
        return '标准';
    }
  }
}
