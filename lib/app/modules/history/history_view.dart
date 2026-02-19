import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/models/transaction.dart';
import '../../core/crypto/coins/coin_registry.dart';
import '../../core/widgets/empty_state_widget.dart';
import 'history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

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
            AppStrings.txHistory,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Column(
          children: [
            // Filter chips
            _buildFilterChips(),
            SizedBox(height: 8.h),
            // Transaction list
            Expanded(
              child: Obx(() {
                if (controller.filteredTransactions.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.receipt_long,
                    title: AppStrings.noTransactions,
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: controller.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = controller.filteredTransactions[index];
                    return _buildTxItem(tx);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40.h,
      child: Obx(() {
        final wallet = controller.walletService.currentWallet.value;
        final activeCoins = wallet?.activeCoins ?? [];

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            _buildChip('全部', '', controller.selectedCoinId.value.isEmpty),
            ...activeCoins.map((coinId) {
              final coin = CoinRegistry.getById(coinId);
              return _buildChip(
                coin?.symbol ?? coinId,
                coinId,
                controller.selectedCoinId.value == coinId,
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildChip(String label, String coinId, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.filterByCoin(coinId.isEmpty ? null : coinId),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.darkCard,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTxItem(Transaction tx) {
    final isOutgoing = tx.direction == TransactionDirection.outgoing;
    final statusColor = _getStatusColor(tx.status);

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.historyDetail, arguments: {'tx': tx});
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Direction icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: (isOutgoing ? AppColors.error : AppColors.success)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
                color: isOutgoing ? AppColors.error : AppColors.success,
                size: 20.w,
              ),
            ),
            SizedBox(width: 12.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.formatTxAmount(tx),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isOutgoing ? AppColors.error : AppColors.success,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    controller.shortenAddress(
                        isOutgoing ? tx.toAddress : tx.fromAddress),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            // Time and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatTxTime(tx.createdAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _getStatusLabel(tx.status),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirmed:
        return AppColors.success;
      case TransactionStatus.pending:
      case TransactionStatus.broadcasting:
        return AppColors.warning;
      case TransactionStatus.failed:
        return AppColors.error;
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirmed:
        return AppStrings.confirmed;
      case TransactionStatus.pending:
        return AppStrings.pending;
      case TransactionStatus.broadcasting:
        return '广播中';
      case TransactionStatus.failed:
        return AppStrings.failed;
    }
  }
}
