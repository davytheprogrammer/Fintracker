import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/constants.dart';

enum AppThemeMode { light, dark, system }

enum ConnectivityStatus { none, wifi, mobile, ethernet }

class AppProvider with ChangeNotifier {
  // Theme management
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isDarkMode = false;

  // Connectivity
  ConnectivityStatus _connectivityStatus = ConnectivityStatus.none;
  bool _isOnline = false;

  // App state
  bool _isInitialized = false;
  String _appVersion = '1.0.0';
  Locale _locale = const Locale('en');

  // Loading states
  bool _isGlobalLoading = false;
  String? _globalLoadingMessage;

  // Getters
  AppThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  ConnectivityStatus get connectivityStatus => _connectivityStatus;
  bool get isOnline => _isOnline;
  bool get isInitialized => _isInitialized;
  String get appVersion => _appVersion;
  Locale get locale => _locale;
  bool get isGlobalLoading => _isGlobalLoading;
  String? get globalLoadingMessage => _globalLoadingMessage;

  // Theme methods
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    _updateDarkMode();
    _saveThemePreference(mode);
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    _updateDarkMode();
    _saveThemePreference(_themeMode);
    notifyListeners();
  }

  void _updateDarkMode() {
    switch (_themeMode) {
      case AppThemeMode.light:
        _isDarkMode = false;
        break;
      case AppThemeMode.dark:
        _isDarkMode = true;
        break;
      case AppThemeMode.system:
        _isDarkMode = false;
        break;
    }
  }

  Future<void> _saveThemePreference(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.name);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
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

      // Initialize connectivity — assume online for now
      updateConnectivityStatus(ConnectivityStatus.wifi);

      // Load saved preferences
      await _loadSavedPreferences();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize app: $e');
    } finally {
      _setGlobalLoading(false);
    }
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme != null) {
        _themeMode = AppThemeMode.values.firstWhere(
          (e) => e.name == savedTheme,
          orElse: () => AppThemeMode.system,
        );
        _updateDarkMode();
      }

      // Load locale
      final savedLocale = prefs.getString('locale');
      if (savedLocale != null) {
        _locale = Locale(savedLocale);
      }
    } catch (e) {
      debugPrint('Failed to load saved preferences: $e');
    }
  }

  // Locale methods
  void setLocale(Locale locale) {
    _locale = locale;
    _saveLocalePreference(locale);
    notifyListeners();
  }

  Future<void> _saveLocalePreference(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', locale.languageCode);
    } catch (e) {
      debugPrint('Failed to save locale preference: $e');
    }
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
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
    _themeMode = AppThemeMode.system;
    _locale = const Locale('en');
    _updateDarkMode();
    notifyListeners();
  }
}
