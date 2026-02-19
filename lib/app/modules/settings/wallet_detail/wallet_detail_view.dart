import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../theme/app_colors.dart';
import 'wallet_detail_controller.dart';

class WalletDetailView extends GetView<WalletDetailController> {
  const WalletDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('钱包详情'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Wallet Info Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.walletName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.walletName,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12.h),
                Text(
                  '钱包类型',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.walletType,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Coin Details
          ...controller.coinDetails.map((coin) => _coinCard(coin)),
        ],
      ),
    );
  }

  Widget _coinCard(Map<String, String> coin) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol Header
          Text(
            coin['symbol'] ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),

          // Derivation Path
          _detailRow(
            label: AppStrings.derivationPath,
            value: coin['path'] ?? '-',
          ),
          SizedBox(height: 8.h),

          // Address
          _detailRow(
            label: '地址',
            value: coin['address'] ?? '-',
            copiable: true,
            onCopy: () => controller.copyAddress(coin['coinId']!),
          ),
          SizedBox(height: 8.h),

          // Extended Public Key (collapsible)
          _xpubSection(coin),
        ],
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    bool copiable = false,
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (copiable && onCopy != null)
              IconButton(
                icon: Icon(Icons.copy, size: 16.sp),
                onPressed: onCopy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _xpubSection(Map<String, String> coin) {
    final xpub = coin['xpub'] ?? '-';
    if (xpub == '-') return const SizedBox.shrink();

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(
        AppStrings.exportPublicKey,
        style: TextStyle(fontSize: 13.sp, color: AppColors.textHint),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: SelectableText(
                xpub,
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, size: 16.sp),
              onPressed: () => controller.copyXpub(coin['coinId']!),
            ),
          ],
        ),
      ],
    );
  }
}
