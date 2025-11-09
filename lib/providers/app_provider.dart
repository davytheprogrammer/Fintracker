import 'package:flutter/material.dart';
import '../shared/constants.dart';

enum ThemeMode { light, dark, system }

enum ConnectivityStatus { none, wifi, mobile, ethernet }

class AppProvider with ChangeNotifier {
  // Theme management
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  // Connectivity
  ConnectivityStatus _connectivityStatus = ConnectivityStatus.none;
  bool _isOnline = false;

  // App state
  bool _isInitialized = false;
  String? _appVersion;
  Locale _locale = const Locale('en');

  // Loading states
  bool _isGlobalLoading = false;
  String? _globalLoadingMessage;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  ConnectivityStatus get connectivityStatus => _connectivityStatus;
  bool get isOnline => _isOnline;
  bool get isInitialized => _isInitialized;
  String? get appVersion => _appVersion;
  Locale get locale => _locale;
  bool get isGlobalLoading => _isGlobalLoading;
  String? get globalLoadingMessage => _globalLoadingMessage;

  // Theme methods
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _updateDarkMode();
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _updateDarkMode();
    notifyListeners();
  }

  void _updateDarkMode() {
    switch (_themeMode) {
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
      case ThemeMode.system:
        // This would typically check system preference
        // For now, default to light mode
        _isDarkMode = false;
        break;
    }
  }

  // Connectivity methods
  void updateConnectivityStatus(ConnectivityStatus status) {
    _connectivityStatus = status;
    _isOnline = status != ConnectivityStatus.none;
    notifyListeners();
  }

  // App initialization
  Future<void> initializeApp() async {
    if (_isInitialized) return;

    try {
      _setGlobalLoading(true, 'Initializing app...');

      // Initialize connectivity monitoring
      await _initializeConnectivity();

      // Load app version
      await _loadAppVersion();

      // Load saved preferences
      await _loadSavedPreferences();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize app: $e');
    } finally {
      _setGlobalLoading(false);
    }
  }

  Future<void> _initializeConnectivity() async {
    try {
      // TODO: Initialize connectivity monitoring when connectivity_plus is added
      // For now, assume online
      updateConnectivityStatus(ConnectivityStatus.wifi);
    } catch (e) {
      debugPrint('Failed to initialize connectivity: $e');
    }
  }

  Future<void> _loadAppVersion() async {
    // TODO: Load app version from package info
    // For now, set a placeholder
    _appVersion = '1.0.0';
  }

  Future<void> _loadSavedPreferences() async {
    // TODO: Load saved theme preference, locale, etc. from shared preferences
    // For now, use defaults
  }

  // Locale methods
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  // Global loading methods
  void setGlobalLoading(bool loading, {String? message}) {
    _setGlobalLoading(loading, message);
  }

  void _setGlobalLoading(bool loading, [String? message]) {
    _isGlobalLoading = loading;
    _globalLoadingMessage = message;
    notifyListeners();
  }

  // Theme data getters
  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: isDark ? AppColors.surfaceDark : AppColors.surface,
        background: isDark ? AppColors.backgroundDark : AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        onBackground:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
        ),
      ),

      // Component themes
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      cardTheme: const CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),

      // Additional customizations
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      dividerColor: isDark ? AppColors.borderDark : AppColors.divider,
    );
  }

  // Utility methods
  void resetToDefaults() {
    _themeMode = ThemeMode.system;
    _locale = const Locale('en');
    _updateDarkMode();
    notifyListeners();
  }

  // Debug methods
  void printCurrentState() {
    debugPrint('AppProvider State:');
    debugPrint('  Theme Mode: $_themeMode');
    debugPrint('  Is Dark Mode: $_isDarkMode');
    debugPrint('  Connectivity: $_connectivityStatus');
    debugPrint('  Is Online: $_isOnline');
    debugPrint('  Is Initialized: $_isInitialized');
    debugPrint('  Locale: $_locale');
    debugPrint('  Global Loading: $_isGlobalLoading');
  }
}
