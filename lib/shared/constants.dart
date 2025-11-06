import 'package:flutter/material.dart';

// ============================================================================
// FinSpense Design System - Next Generation Financial Tracking
// ============================================================================

/// Modern Color Palette
class AppColors {
  // Primary Colors - Elegant Purple Gradient
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF5147E5);
  static const primaryLight = Color(0xFF8B85FF);

  // Accent Colors - Vibrant Coral/Pink
  static const accent = Color(0xFFFF6B9D);
  static const accentLight = Color(0xFFFF8FB5);
  static const accentDark = Color(0xFFE5527A);

  // Success, Warning, Error
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFF81C784);
  static const warning = Color(0xFFFFB74D);
  static const warningLight = Color(0xFFFFCC80);
  static const error = Color(0xFFEF5350);
  static const errorLight = Color(0xFFE57373);

  // Income & Expense Colors
  static const income = Color(0xFF4CAF50);
  static const expense = Color(0xFFFF5252);

  // Neutral Colors - Light Mode
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F7);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFF3F4F6);

  // Dark Mode Colors
  static const backgroundDark = Color(0xFF0F0F1E);
  static const surfaceDark = Color(0xFF1A1A2E);
  static const surfaceVariantDark = Color(0xFF252537);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFB8B9BE);
  static const textTertiaryDark = Color(0xFF8A8A8E);
  static const borderDark = Color(0xFF2C2C3E);

  // Glassmorphism
  static const glassLight = Color(0xCCFFFFFF);
  static const glassDark = Color(0xCC1A1A2E);

  // Gradient Colors (using getters for runtime list creation)
  static List<Color> get primaryGradient => [
        const Color(0xFF6C63FF),
        const Color(0xFF8B85FF),
      ];

  static List<Color> get accentGradient => [
        const Color(0xFFFF6B9D),
        const Color(0xFFFF8FB5),
      ];

  static List<Color> get successGradient => [
        const Color(0xFF4CAF50),
        const Color(0xFF81C784),
      ];

  static List<Color> get backgroundGradient => [
        const Color(0xFFF8F9FA),
        const Color(0xFFE8EAF6),
      ];

  static List<Color> get darkBackgroundGradient => [
        const Color(0xFF0F0F1E),
        const Color(0xFF1A1A2E),
      ];

  // Category Colors
  static Map<String, Color> get categoryColors => {
        'Food': const Color(0xFFFF6B6B),
        'Transport': const Color(0xFF4ECDC4),
        'Shopping': const Color(0xFFFFBE0B),
        'Entertainment': const Color(0xFFFB5607),
        'Healthcare': const Color(0xFF8338EC),
        'Education': const Color(0xFF3A86FF),
        'Bills': const Color(0xFFFF006E),
        'Groceries': const Color(0xFF06FFA5),
        'Rent': const Color(0xFF590D82),
        'Other': const Color(0xFF95A5A6),
      };
}

/// Typography System
class AppTypography {
  static const String fontFamily = 'SF Pro Display';

  // Display Styles
  static const displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  static const displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline Styles
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title Styles
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body Styles
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label Styles
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}

/// Spacing System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Border Radius System
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 9999.0;
}

/// Elevation & Shadow System
class AppShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // Colored Shadows
  static List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> accent = [
    BoxShadow(
      color: AppColors.accent.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Animation Durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// Modern Input Decoration with Glassmorphism
InputDecoration modernInputDecoration({
  required String label,
  required IconData icon,
  String? hint,
  Widget? suffix,
  bool isDark = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.primary),
    suffixIcon: suffix,
    filled: true,
    fillColor:
        isDark ? AppColors.surfaceDark.withOpacity(0.5) : AppColors.surface,
    labelStyle: AppTypography.bodyMedium.copyWith(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.border,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  );
}

/// Glassmorphism Card Decoration
BoxDecoration glassCardDecoration({
  bool isDark = false,
  List<Color>? gradientColors,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.xl),
    gradient: gradientColors != null
        ? LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null,
    color: gradientColors == null
        ? (isDark ? AppColors.glassDark : AppColors.glassLight)
        : null,
    border: Border.all(
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
      width: 1,
    ),
    boxShadow: isDark ? AppShadows.medium : AppShadows.large,
  );
}

/// Modern Gradient Button Decoration
BoxDecoration gradientButtonDecoration({
  List<Color>? colors,
  double radius = AppRadius.md,
}) {
  final usedColors = colors ?? AppColors.primaryGradient;
  return BoxDecoration(
    gradient: LinearGradient(
      colors: usedColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: AppShadows.medium,
  );
}

// Legacy support - kept for backwards compatibility
const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromRGBO(134, 148, 133, 1), width: 2.0),
  ),
);
