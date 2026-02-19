import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const primaryBlue = Color(0xFF1A73E8);
  static const primaryBlueDark = Color(0xFF1557B0);
  static const accentGold = Color(0xFFF4B942);
  static const accentGoldDark = Color(0xFFD4992A);

  // Background Colors (Dark Mode)
  static const darkBg = Color(0xFF0D0D0D);
  static const darkCard = Color(0xFF1A1A2E);
  static const darkCardSecondary = Color(0xFF16213E);
  static const darkSurface = Color(0xFF0F3460);
  static const darkDivider = Color(0xFF2A2A3E);

  // Background Colors (Light Mode)
  static const lightBg = Color(0xFFF5F7FA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardSecondary = Color(0xFFF0F2F5);
  static const lightSurface = Color(0xFFE8EEFF);
  static const lightDivider = Color(0xFFE0E0E0);

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B8CC);
  static const textHint = Color(0xFF6B7280);
  static const textLight = Color(0xFF1A1A2E);
  static const textLightSecondary = Color(0xFF6B7280);

  // Status Colors
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);

  // Coin Colors
  static const btcOrange = Color(0xFFF7931A);
  static const ethBlue = Color(0xFF627EEA);
  static const trxRed = Color(0xFFE50914);
  static const bnbYellow = Color(0xFFF3BA2F);
  static const usdtGreen = Color(0xFF26A17B);

  // Gradient
  static const cardGradientStart = Color(0xFF1A1A2E);
  static const cardGradientEnd = Color(0xFF16213E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF0F3460)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF4B942), Color(0xFFD4992A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [cardGradientStart, cardGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
