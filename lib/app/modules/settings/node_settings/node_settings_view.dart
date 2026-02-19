import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../theme/app_colors.dart';
import 'node_settings_controller.dart';

class NodeSettingsView extends GetView<NodeSettingsController> {
  const NodeSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.networkNodes),
        actions: [
          TextButton(
            onPressed: controller.resetAllToDefault,
            child: Text(
              '全部重置',
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Warning Banner
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.warningLight.withAlpha(30),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.warning.withAlpha(76)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '自定义节点可能影响交易安全，请确保使用可信的RPC节点。',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Node Inputs
          ...NodeSettingsController.defaultNodes.keys.map((chainId) {
            return _nodeInputSection(chainId);
          }),

          SizedBox(height: 24.h),

          // Save Button
          Obx(() => ElevatedButton(
                onPressed:
                    controller.isSaving.value ? null : controller.saveNodes,
                child: controller.isSaving.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppStrings.save, style: TextStyle(fontSize: 15.sp)),
              )),
        ],
      ),
    );
  }

  Widget _nodeInputSection(String chainId) {
    final name = NodeSettingsController.chainNames[chainId] ?? chainId;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => controller.resetToDefault(chainId),
                child: Text(
                  '恢复默认',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          TextField(
            controller: controller.nodeControllers[chainId],
            style: TextStyle(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: NodeSettingsController.defaultNodes[chainId],
              hintStyle: TextStyle(fontSize: 12.sp),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }
}
