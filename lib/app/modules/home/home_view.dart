import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../core/values/app_strings.dart';
import 'home_controller.dart';
import 'widgets/total_balance_widget.dart';
import 'widgets/coin_card_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            const TotalBalanceWidget(),
            SizedBox(height: 8.h),
            // Coin list
            Expanded(
              child: Obx(() {
                if (controller.coinItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64.w,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppStrings.manageCurrencies,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 80.h),
                  itemCount: controller.coinItems.length,
                  itemBuilder: (context, index) {
                    return Obx(() => CoinCardWidget(
                          item: controller.coinItems[index],
                          isSelected:
                              controller.selectedCoinIndex.value == index,
                          hideBalance: controller.hideBalance.value,
                          onTap: () => controller.selectCoin(index),
                        ));
                  },
                );
              }),
            ),
          ],
        ),
        // Floating action bar when coin is selected
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(() {
          final selected = controller.selectedCoin;
          if (selected == null) return const SizedBox.shrink();

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.arrow_upward,
                    label: AppStrings.send,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.send,
                        arguments: {'coinId': selected.coinInfo.id},
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.arrow_downward,
                    label: AppStrings.receive,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.receive,
                        arguments: {'coinId': selected.coinInfo.id},
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      title: Obx(() => Text(
            controller.walletService.currentWallet.value?.name ?? 'Solo Wallet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          )),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textPrimary, size: 24.w),
          color: AppColors.darkCard,
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                controller.refreshBalances();
                break;
              case 'manage':
                Get.toNamed(AppRoutes.manageCoin);
                break;
              case 'addToken':
                Get.toNamed(AppRoutes.addToken);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20.w, color: AppColors.textPrimary),
                  SizedBox(width: 8.w),
                  Text(
                    '刷新',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'manage',
              child: Row(
                children: [
                  Icon(Icons.tune, size: 20.w, color: AppColors.textPrimary),
                  SizedBox(width: 8.w),
                  Text(
                    AppStrings.manageCurrencies,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'addToken',
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 20.w, color: AppColors.textPrimary),
                  SizedBox(width: 8.w),
                  Text(
                    AppStrings.addCustomToken,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(
          top: BorderSide(color: AppColors.darkDivider, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textHint,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Already on home
            case 1:
              Get.toNamed(AppRoutes.history);
              break;
            case 2:
              // QR scan shortcut
              break;
            case 3:
              Get.toNamed(AppRoutes.security);
              break;
            case 4:
              Get.toNamed(AppRoutes.settings);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '资产',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '历史',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '扫码',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: '安全',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
