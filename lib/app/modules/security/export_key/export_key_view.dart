import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/values/app_constants.dart';
import '../../../theme/app_colors.dart';
import 'export_key_controller.dart';

class ExportKeyView extends GetView<ExportKeyController> {
  const ExportKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导出私钥'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Warning Banner
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(25),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.error.withAlpha(76)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppStrings.privateKeyWarning,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Coin Selector
            if (controller.availableCoins.length > 1) ...[
              Text(
                '选择币种',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: controller.availableCoins.map((coinId) {
                  final isSelected = coinId == controller.coinId;
                  return ChoiceChip(
                    label: Text(
                      _coinLabel(coinId),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue.withAlpha(51),
                    onSelected: (_) => controller.selectCoin(coinId),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
            ],

            // Private Key Display
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '私钥',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Obx(() => Icon(
                              controller.isKeyVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20.sp,
                            )),
                        onPressed: controller.toggleVisibility,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Obx(() {
                    final key = controller.privateKey.value;
                    if (key.isEmpty) {
                      return Text(
                        '暂无私钥数据',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textHint,
                        ),
                      );
                    }
                    return SelectableText(
                      controller.isKeyVisible.value
                          ? key
                          : '*' * key.length.clamp(0, 64),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // QR Code
            Obx(() {
              final key = controller.privateKey.value;
              if (key.isEmpty || !controller.isKeyVisible.value) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: QrImageView(
                    data: key,
                    version: QrVersions.auto,
                    size: AppConstants.qrSize,
                  ),
                ),
              );
            }),
            SizedBox(height: 24.h),

            // Copy Button
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.privateKey.value.isNotEmpty
                      ? controller.copyKey
                      : null,
                  icon: Icon(Icons.copy, size: 18.sp),
                  label: Text(
                    '复制私钥',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                )),
          ],
        );
      }),
    );
  }

  String _coinLabel(String coinId) {
    switch (coinId) {
      case AppConstants.coinBtc:
        return 'BTC';
      case AppConstants.coinEth:
        return 'ETH';
      case AppConstants.coinTrx:
        return 'TRX';
      case AppConstants.coinBnb:
        return 'BNB';
      default:
        return coinId.toUpperCase();
    }
  }
}
