import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/values/app_strings.dart';
import '../../theme/app_colors.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          // Wallet Management Section
          _sectionHeader(AppStrings.walletManagement),
          Obx(() => _listTile(
                icon: Icons.account_balance_wallet,
                title: AppStrings.walletName,
                subtitle: controller.walletService.currentWallet.value?.name ?? '-',
                onTap: controller.navigateToWalletDetail,
              )),
          _listTile(
            icon: Icons.route,
            title: AppStrings.derivationPath,
            subtitle: 'BIP44',
            onTap: controller.navigateToWalletDetail,
          ),
          _listTile(
            icon: Icons.key,
            title: AppStrings.exportPublicKey,
            onTap: controller.navigateToWalletDetail,
          ),
          const Divider(),

          // App Settings Section
          _sectionHeader(AppStrings.appSettings),
          _listTile(
            icon: Icons.lock,
            title: AppStrings.changePin,
            onTap: controller.navigateToChangePin,
          ),
          Obx(() => _switchTile(
                icon: Icons.fingerprint,
                title: AppStrings.biometricAuth,
                value: controller.biometricEnabled.value,
                enabled: controller.isBiometricAvailable.value,
                onChanged: controller.toggleBiometric,
              )),
          Obx(() => _dropdownTile(
                icon: Icons.attach_money,
                title: AppStrings.fiatCurrency,
                value: controller.fiatCurrency.value,
                items: const ['CNY', 'USD', 'EUR', 'JPY', 'KRW', 'GBP'],
                onChanged: (v) {
                  if (v != null) controller.changeFiatCurrency(v);
                },
              )),
          const Divider(),

          // Network Nodes Section
          _sectionHeader(AppStrings.networkNodes),
          _listTile(
            icon: Icons.dns,
            title: '自定义节点',
            onTap: controller.navigateToNodeSettings,
          ),
          const Divider(),

          // Security Section
          _sectionHeader(AppStrings.securityCenter),
          _listTile(
            icon: Icons.security,
            title: AppStrings.securityCenter,
            onTap: controller.navigateToSecurity,
          ),
          const Divider(),

          // About Section
          _sectionHeader('关于'),
          _listTile(
            icon: Icons.info_outline,
            title: '版本',
            subtitle: '1.0.0',
          ),
          SizedBox(height: 24.h),

          // Danger Zone
          _dangerButton('删除钱包', onTap: controller.confirmDeleteWallet),
          SizedBox(height: 40.h),
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
    IconData? icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, size: 22.sp, color: AppColors.textSecondary)
          : null,
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 13.sp, color: AppColors.textHint))
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
    required bool value,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22.sp, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _dropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22.sp, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.darkCard,
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dangerButton(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          minimumSize: Size(double.infinity, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(title, style: TextStyle(fontSize: 15.sp)),
      ),
    );
  }
}
