import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/models/transaction.dart';
import 'history_controller.dart';

class HistoryDetailView extends GetView<HistoryController> {
  const HistoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final tx = args['tx'] as Transaction;
    final coinInfo = controller.getCoinInfo(tx.coinId);

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
            '交易详情',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                Center(
                  child: Column(
                    children: [
                      Text(
                        controller.formatTxAmount(tx),
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: tx.direction == TransactionDirection.outgoing
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildStatusBadge(tx.status),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Divider(color: AppColors.darkDivider),
                SizedBox(height: 16.h),

                // Transaction hash
                if (tx.txHash != null)
                  _buildDetailRow(
                    AppStrings.txHash,
                    tx.txHash!,
                    canCopy: true,
                  ),

                // From address
                _buildDetailRow(
                  AppStrings.fromAddress,
                  tx.fromAddress,
                  canCopy: true,
                ),

                // To address
                _buildDetailRow(
                  AppStrings.toAddress,
                  tx.toAddress,
                  canCopy: true,
                ),

                // Amount
                _buildDetailRow(
                  AppStrings.amount,
                  coinInfo != null
                      ? '${coinInfo.formatAmount(tx.amount)} ${coinInfo.symbol}'
                      : tx.amount.toString(),
                ),

                // Fee
                if (tx.fee != null)
                  _buildDetailRow(
                    AppStrings.fee,
                    coinInfo != null
                        ? '${coinInfo.formatAmount(tx.fee!)} ${coinInfo.symbol}'
                        : tx.fee.toString(),
                  ),

                // Confirmations
                if (tx.confirmations != null)
                  _buildDetailRow(
                    AppStrings.confirmations,
                    tx.confirmations.toString(),
                  ),

                // Time
                _buildDetailRow(
                  AppStrings.time,
                  _formatFullTime(tx.createdAt),
                ),

                // Confirmed time
                if (tx.confirmedAt != null)
                  _buildDetailRow(
                    '确认时间',
                    _formatFullTime(tx.confirmedAt!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool canCopy = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                    fontFamily: canCopy ? 'monospace' : null,
                  ),
                ),
              ),
              if (canCopy)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    Get.snackbar('已复制', '$label已复制',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1));
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16.w,
                    color: AppColors.primaryBlue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    Color color;
    String label;
    switch (status) {
      case TransactionStatus.confirmed:
        color = AppColors.success;
        label = AppStrings.confirmed;
        break;
      case TransactionStatus.pending:
        color = AppColors.warning;
        label = AppStrings.pending;
        break;
      case TransactionStatus.broadcasting:
        color = AppColors.warning;
        label = '广播中';
        break;
      case TransactionStatus.failed:
        color = AppColors.error;
        label = AppStrings.failed;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatFullTime(DateTime time) {
    return '${time.year}-'
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
