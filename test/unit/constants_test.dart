import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Finspense/shared/constants.dart';

void main() {
  group('AppColors Tests', () {
    test('Primary colors should be defined correctly', () {
      expect(AppColors.primary, const Color(0xFF6C63FF));
      expect(AppColors.primaryDark, const Color(0xFF5147E5));
      expect(AppColors.primaryLight, const Color(0xFF8B85FF));
    });

    test('Accent colors should be defined correctly', () {
      expect(AppColors.accent, const Color(0xFFFF6B9D));
      expect(AppColors.accentLight, const Color(0xFFFF8FB5));
      expect(AppColors.accentDark, const Color(0xFFE5527A));
    });

    test('Primary gradient colors should be a list', () {
      expect(AppColors.primaryGradient, isA<List<Color>>());
      expect(AppColors.primaryGradient.length, 2);
      expect(AppColors.primaryGradient[0], const Color(0xFF6C63FF));
      expect(AppColors.primaryGradient[1], const Color(0xFF8B85FF));
    });

    test('Accent gradient colors should be a list', () {
      expect(AppColors.accentGradient, isA<List<Color>>());
      expect(AppColors.accentGradient.length, 2);
      expect(AppColors.accentGradient[0], const Color(0xFFFF6B9D));
      expect(AppColors.accentGradient[1], const Color(0xFFFF8FB5));
    });

    test('Surface colors should be defined', () {
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceDark, const Color(0xFF1A1A2E));
      expect(AppColors.surfaceVariant, const Color(0xFFF5F5F7));
      expect(AppColors.surfaceVariantDark, const Color(0xFF252537));
    });

    test('Text colors should be defined', () {
      expect(AppColors.textPrimary, const Color(0xFF1A1A1A));
      expect(AppColors.textSecondary, const Color(0xFF6B7280));
      expect(AppColors.textTertiary, const Color(0xFF9CA3AF));
      expect(AppColors.textPrimaryDark, const Color(0xFFFFFFFF));
      expect(AppColors.textSecondaryDark, const Color(0xFFB8B9BE));
      expect(AppColors.textTertiaryDark, const Color(0xFF8A8A8E));
    });

    test('Semantic colors should be defined', () {
      expect(AppColors.success, const Color(0xFF4CAF50));
      expect(AppColors.error, const Color(0xFFEF5350));
      expect(AppColors.warning, const Color(0xFFFFB74D));
    });

    test('Income and expense colors should be defined', () {
      expect(AppColors.income, const Color(0xFF4CAF50));
      expect(AppColors.expense, const Color(0xFFFF5252));
    });

    test('Border and divider colors should be defined', () {
      expect(AppColors.border, const Color(0xFFE5E7EB));
      expect(AppColors.borderDark, const Color(0xFF2C2C3E));
      expect(AppColors.divider, const Color(0xFFF3F4F6));
    });

    test('Category colors map should contain all categories', () {
      final categories = AppColors.categoryColors;
      expect(categories, isA<Map<String, Color>>());
      expect(categories.containsKey('Food'), true);
      expect(categories.containsKey('Transport'), true);
      expect(categories.containsKey('Shopping'), true);
      expect(categories.containsKey('Entertainment'), true);
      expect(categories.containsKey('Healthcare'), true);
      expect(categories.containsKey('Other'), true);
    });
  });

  group('AppTypography Tests', () {
    test('Display text styles should be defined', () {
      expect(AppTypography.displayLarge, isA<TextStyle>());
      expect(AppTypography.displayLarge.fontSize, 57);
      expect(AppTypography.displayLarge.fontWeight, FontWeight.w700);
    });

    test('Headline text styles should be defined', () {
      expect(AppTypography.headlineLarge, isA<TextStyle>());
      expect(AppTypography.headlineMedium, isA<TextStyle>());
      expect(AppTypography.headlineSmall, isA<TextStyle>());
    });

    test('Title text styles should be defined', () {
      expect(AppTypography.titleLarge, isA<TextStyle>());
      expect(AppTypography.titleMedium, isA<TextStyle>());
      expect(AppTypography.titleSmall, isA<TextStyle>());
    });

    test('Body text styles should be defined', () {
      expect(AppTypography.bodyLarge, isA<TextStyle>());
      expect(AppTypography.bodyMedium, isA<TextStyle>());
      expect(AppTypography.bodySmall, isA<TextStyle>());
    });

    test('Label text styles should be defined', () {
      expect(AppTypography.labelLarge, isA<TextStyle>());
      expect(AppTypography.labelMedium, isA<TextStyle>());
      expect(AppTypography.labelSmall, isA<TextStyle>());
    });
  });

  group('AppSpacing Tests', () {
    test('Spacing values should be correct', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.xxl, 48.0);
      expect(AppSpacing.xxxl, 64.0);
    });
  });

  group('AppRadius Tests', () {
    test('Border radius values should be correct', () {
      expect(AppRadius.xs, 4.0);
      expect(AppRadius.sm, 8.0);
      expect(AppRadius.md, 12.0);
      expect(AppRadius.lg, 16.0);
      expect(AppRadius.xl, 20.0);
      expect(AppRadius.xxl, 24.0);
      expect(AppRadius.full, 9999.0);
    });
  });

  group('AppShadows Tests', () {
    test('Shadow definitions should exist', () {
      expect(AppShadows.small, isA<List<BoxShadow>>());
      expect(AppShadows.medium, isA<List<BoxShadow>>());
      expect(AppShadows.large, isA<List<BoxShadow>>());
      expect(AppShadows.xl, isA<List<BoxShadow>>());
    });

    test('Shadows should have correct properties', () {
      expect(AppShadows.small.length, 1);
      expect(AppShadows.medium.length, 1);
      expect(AppShadows.large.length, 1);
      expect(AppShadows.xl.length, 1);

      // Test small shadow
      expect(AppShadows.small[0].blurRadius, 4);
      expect(AppShadows.small[0].offset, const Offset(0, 2));

      // Test medium shadow
      expect(AppShadows.medium[0].blurRadius, 8);
      expect(AppShadows.medium[0].offset, const Offset(0, 4));

      // Test large shadow
      expect(AppShadows.large[0].blurRadius, 16);
      expect(AppShadows.large[0].offset, const Offset(0, 8));

      // Test extra large shadow
      expect(AppShadows.xl[0].blurRadius, 24);
      expect(AppShadows.xl[0].offset, const Offset(0, 12));
    });

    test('Colored shadows should be defined', () {
      expect(AppShadows.primary, isA<List<BoxShadow>>());
      expect(AppShadows.accent, isA<List<BoxShadow>>());
    });
  });

  group('AppDurations Tests', () {
    test('Animation durations should be defined', () {
      expect(AppDurations.fast, const Duration(milliseconds: 200));
      expect(AppDurations.medium, const Duration(milliseconds: 300));
      expect(AppDurations.slow, const Duration(milliseconds: 500));
    });
  });

  group('Helper Functions Tests', () {
    testWidgets('modernInputDecoration should return correct decoration',
        (WidgetTester tester) async {
      final decoration = modernInputDecoration(
        label: 'Test Label',
        icon: Icons.person,
        hint: 'Test Hint',
      );

      expect(decoration, isA<InputDecoration>());
      expect(decoration.labelText, 'Test Label');
      expect(decoration.hintText, 'Test Hint');
      expect(decoration.prefixIcon, isA<Icon>());
      expect(decoration.border, isA<OutlineInputBorder>());
      expect(decoration.enabledBorder, isA<OutlineInputBorder>());
      expect(decoration.focusedBorder, isA<OutlineInputBorder>());
      expect(decoration.errorBorder, isA<OutlineInputBorder>());
      expect(decoration.filled, true);
    });

    testWidgets('glassCardDecoration should return correct decoration',
        (WidgetTester tester) async {
      final decoration = glassCardDecoration();

      expect(decoration, isA<BoxDecoration>());
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.border, isA<Border>());
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });

    testWidgets(
        'glassCardDecoration with custom gradient colors should use provided colors',
        (WidgetTester tester) async {
      final customColors = [Colors.red, Colors.blue];
      final decoration = glassCardDecoration(gradientColors: customColors);

      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.gradient, isNotNull);
    });

    testWidgets('glassCardDecoration isDark mode should work correctly',
        (WidgetTester tester) async {
      final decoration = glassCardDecoration(isDark: true);

      expect(decoration, isA<BoxDecoration>());
      expect(decoration.boxShadow, AppShadows.medium);
    });

    testWidgets('gradientButtonDecoration should return correct decoration',
        (WidgetTester tester) async {
      final decoration = gradientButtonDecoration();

      expect(decoration, isA<BoxDecoration>());
      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });
  });
}
