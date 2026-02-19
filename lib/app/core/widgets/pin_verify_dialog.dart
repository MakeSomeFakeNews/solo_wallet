import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../values/app_constants.dart';
import '../values/app_strings.dart';

class PinVerifyDialog extends StatefulWidget {
  const PinVerifyDialog({super.key});

  static Future<bool> show() async {
    return await Get.dialog<bool>(const PinVerifyDialog()) ?? false;
  }

  @override
  State<PinVerifyDialog> createState() => _PinVerifyDialogState();
}

class _PinVerifyDialogState extends State<PinVerifyDialog> {
  final SecurityService _securityService = Get.find();
  String _pin = '';
  String? _errorText;
  bool _isVerifying = false;

  void _onKeyTap(String digit) {
    if (_pin.length >= AppConstants.pinLength) return;
    setState(() {
      _pin += digit;
      _errorText = null;
    });
    if (_pin.length == AppConstants.pinLength) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorText = null;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final result = await _securityService.verifyPin(_pin);
    setState(() => _isVerifying = false);
    if (result) {
      Get.back(result: true);
    } else {
      setState(() {
        _pin = '';
        _errorText = _securityService.remainingAttempts > 0
            ? '${AppStrings.wrongPin}，剩余${_securityService.remainingAttempts}次'
            : AppStrings.pinLocked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.pinVerificationRequired,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppStrings.enterPin,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(AppConstants.pinLength, (index) {
                final filled = index < _pin.length;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.primaryBlue : Colors.transparent,
                    border: Border.all(
                      color: filled ? AppColors.primaryBlue : AppColors.textHint,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            if (_errorText != null) ...[
              SizedBox(height: 12.h),
              Text(
                _errorText!,
                style: TextStyle(color: AppColors.error, fontSize: 13.sp),
              ),
            ],
            if (_isVerifying) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
            SizedBox(height: 24.h),
            // Number pad
            _buildNumberPad(),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(AppStrings.cancel, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return SizedBox(width: 64.w, height: 48.h);
            }
            if (key == 'del') {
              return InkWell(
                onTap: _onDelete,
                borderRadius: BorderRadius.circular(24.r),
                child: SizedBox(
                  width: 64.w,
                  height: 48.h,
                  child: Icon(Icons.backspace_outlined, size: 22.sp),
                ),
              );
            }
            return InkWell(
              onTap: () => _onKeyTap(key),
              borderRadius: BorderRadius.circular(24.r),
              child: SizedBox(
                width: 64.w,
                height: 48.h,
                child: Center(
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
