import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/values/app_strings.dart';
import '../../theme/app_colors.dart';
import 'security_controller.dart';

class SecurityView extends GetView<SecurityController> {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.securityCenter),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          // Backup Section
          _sectionHeader('备份'),
          _listTile(
            icon: Icons.backup,
            title: AppStrings.backupVerification,
            subtitle: AppStrings.backupVerificationDesc,
            onTap: controller.navigateToBackupVerify,
          ),
          _listTile(
            icon: Icons.visibility,
            title: AppStrings.viewMnemonic,
            subtitle: AppStrings.viewMnemonicDesc,
            onTap: controller.viewMnemonic,
          ),
          _listTile(
            icon: Icons.vpn_key,
            title: '导出私钥',
            subtitle: '需要PIN码验证',
            onTap: controller.navigateToExportKey,
          ),
          const Divider(),

          // Privacy Section
          _sectionHeader('隐私保护'),
          Obx(() => _switchTile(
                icon: Icons.screenshot_monitor,
                title: AppStrings.antiScreenshot,
                subtitle: AppStrings.antiScreenshotDesc,
                value: controller.antiScreenshot.value,
                onChanged: controller.toggleAntiScreenshot,
              )),
          Obx(() => _switchTile(
                icon: Icons.content_paste,
                title: AppStrings.clipboardMonitor,
                subtitle: AppStrings.clipboardMonitorDesc,
                value: controller.clipboardMonitor.value,
                onChanged: controller.toggleClipboardMonitor,
              )),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _listTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22.sp, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
            )
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right, size: 20.sp, color: AppColors.textHint)
          : null,
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22.sp, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
            )
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
