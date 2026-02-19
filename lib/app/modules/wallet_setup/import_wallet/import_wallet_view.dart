import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../theme/app_colors.dart';
import 'import_wallet_controller.dart';

class ImportWalletView extends GetView<ImportWalletController> {
  const ImportWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.importWallet,
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          onTap: (index) => controller.selectedTab.value = index,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 13.sp),
          tabs: const [
            Tab(text: '助记词'),
            Tab(text: '私钥'),
            Tab(text: '观察钱包'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _MnemonicTab(controller: controller),
          _PrivateKeyTab(controller: controller),
          _ExtendedPublicKeyTab(controller: controller),
        ],
      ),
    ));
  }
}

class _MnemonicTab extends StatelessWidget {
  final ImportWalletController controller;

  const _MnemonicTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.enterMnemonic,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCardSecondary,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.darkDivider),
            ),
            child: TextField(
              controller: controller.mnemonicInput,
              maxLines: 4,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.enterMnemonicHint,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => controller.mnemonicError.isNotEmpty
              ? Text(
                  controller.mnemonicError.value,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.error),
                )
              : const SizedBox.shrink()),
          const Spacer(),
          _ImportButton(onTap: controller.validateAndImport),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _PrivateKeyTab extends StatelessWidget {
  final ImportWalletController controller;

  const _PrivateKeyTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.enterPrivateKey,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCardSecondary,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.darkDivider),
            ),
            child: TextField(
              controller: controller.privateKeyInput,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '输入64位十六进制私钥',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Coin selector
          _CoinSelector(controller: controller),

          SizedBox(height: 8.h),
          Obx(() => controller.privateKeyError.isNotEmpty
              ? Text(
                  controller.privateKeyError.value,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.error),
                )
              : const SizedBox.shrink()),
          const Spacer(),
          _ImportButton(onTap: controller.validateAndImport),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _ExtendedPublicKeyTab extends StatelessWidget {
  final ImportWalletController controller;

  const _ExtendedPublicKeyTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.enterExtendedPublicKey,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCardSecondary,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.darkDivider),
            ),
            child: TextField(
              controller: controller.extendedPublicKeyInput,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'xpub / ypub / zpub ...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Coin selector
          _CoinSelector(controller: controller),

          SizedBox(height: 8.h),
          Obx(() => controller.publicKeyError.isNotEmpty
              ? Text(
                  controller.publicKeyError.value,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.error),
                )
              : const SizedBox.shrink()),
          const Spacer(),
          _ImportButton(onTap: controller.validateAndImport),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _CoinSelector extends StatelessWidget {
  final ImportWalletController controller;

  const _CoinSelector({required this.controller});

  static const _coinNames = {
    'btc': 'BTC',
    'eth': 'ETH',
    'trx': 'TRX',
    'bnb': 'BNB',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 10.w,
          children: controller.availableCoins
              .map((coin) => ChoiceChip(
                    label: Text(_coinNames[coin] ?? coin.toUpperCase()),
                    selected: controller.selectedCoinId.value == coin,
                    onSelected: (selected) {
                      if (selected) controller.selectedCoinId.value = coin;
                    },
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.darkCard,
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      color: controller.selectedCoinId.value == coin
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: controller.selectedCoinId.value == coin
                          ? AppColors.primaryBlue
                          : AppColors.darkDivider,
                    ),
                  ))
              .toList(),
        ));
  }
}

class _ImportButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ImportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          '导入',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
