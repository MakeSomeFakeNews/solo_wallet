import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import 'add_token_controller.dart';

class AddTokenView extends GetView<AddTokenController> {
  const AddTokenView({super.key});

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
            AppStrings.addCustomToken,
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
              // Chain selector
              _buildLabel('选择网络'),
              SizedBox(height: 8.h),
              Obx(() => Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedChain.value,
                        isExpanded: true,
                        dropdownColor: AppColors.darkCard,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                        ),
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary),
                        items: controller.supportedChains.map((chain) {
                          return DropdownMenuItem<String>(
                            value: chain['id'],
                            child: Text(chain['name']!),
                          );
                        }).toList(),
                        onChanged: controller.onChainChanged,
                      ),
                    ),
                  )),
              SizedBox(height: 20.h),

              // Contract address
              _buildLabel('合约地址'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.contractController,
                hint: '输入代币合约地址',
                onChanged: controller.onContractChanged,
              ),
              Obx(() {
                if (controller.contractError.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    controller.contractError.value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.error,
                    ),
                  ),
                );
              }),
              SizedBox(height: 20.h),

              // Token name
              _buildLabel('代币名称'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.nameController,
                hint: '例如: Tether USD',
              ),
              SizedBox(height: 20.h),

              // Token symbol
              _buildLabel('代币符号'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.symbolController,
                hint: '例如: USDT',
              ),
              SizedBox(height: 20.h),

              // Decimals
              _buildLabel('精度 (Decimals)'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.decimalsController,
                hint: '18',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 32.h),

              // Add button
              Obx(() => AppButton(
                    text: '添加代币',
                    onPressed: controller.addToken,
                    isLoading: controller.isLoading.value,
                  )),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
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
      ),
    );
  }
}
