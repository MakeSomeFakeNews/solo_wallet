import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../core/crypto/coins/coin_registry.dart';
import '../home_controller.dart';

class CoinCardWidget extends StatelessWidget {
  final CoinBalanceItem item;
  final bool isSelected;
  final bool hideBalance;
  final VoidCallback? onTap;

  const CoinCardWidget({
    super.key,
    required this.item,
    this.isSelected = false,
    this.hideBalance = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final flutterColor = CoinRegistry.getCoinColor(item.coinInfo.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected
              ? Border.all(color: AppColors.primaryBlue, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Coin icon (colored circle with first letter)
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: flutterColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.coinInfo.symbol[0],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: flutterColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Coin name and balance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.coinInfo.symbol,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.coinInfo.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Balance and USD value
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hideBalance ? '****' : item.formattedBalance,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hideBalance ? '****' : item.formattedUsdValue,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
