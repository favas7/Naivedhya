import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static AppThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppThemeColors._(isDark);
  }

  // ============ BRAND COLORS ============
  static const Color primary = Color(0xFFFF971D);
  static const Color primaryLight = Color(0xFFFFB84D);
  static const Color primaryLighter = Color(0xFFFFD699);
  static const Color primaryDark = Color(0xFFE68100);
  static const Color primaryDarker = Color(0xFFCC7000);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBg = Color(0xFFF9F6F7);
  static const Color accent = Color(0xFFFFE8D6);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE63946);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF2196F3);

  // ============ DARK MODE COLORS ============
  static const Color darkPrimary = Color(0xFFFFB84D);
  static const Color darkPrimaryLight = Color(0xFFFFD699);
  static const Color darkPrimaryDarker = Color(0xFFE68100);

  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF242424);

  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkInfo = Color(0xFF42A5F5);

  // ============ TEXT & UI ============
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFBDBDBD);

  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextHint = Color(0xFF666666);

  // ============ ORDER STATUS COLORS ============
  static const Map<String, Color> orderStatusColors = {
    'pending': Color(0xFFFFA726),
    'confirmed': Color(0xFF42A5F5),
    'preparing': Color(0xFF7E57C2),
    'ready': Color(0xFF26A69A),
    'picked up': Color(0xFF5C6BC0),
    'delivering': Color(0xFFFF7043),
    'completed': Color(0xFF66BB6A),
    'cancelled': Color(0xFFEF5350),
  };

  static const Map<String, Color> darkOrderStatusColors = {
    'pending': Color(0xFFFFB74D),
    'confirmed': Color(0xFF64B5F6),
    'preparing': Color(0xFF9575CD),
    'ready': Color(0xFF4DB6AC),
    'picked up': Color(0xFF7986CB),
    'delivering': Color(0xFFFF8A65),
    'completed': Color(0xFF81C784),
    'cancelled': Color(0xFFE57373),
  };

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primary,
      primaryContainer: primaryLight,
      secondary: accent,
      surface: white,
      error: error,
      onPrimary: white,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onError: white,
    ),
    scaffoldBackgroundColor: lightBg,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      foregroundColor: textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: textHint, fontSize: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: _buildTextTheme(textPrimary, textSecondary),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      primaryContainer: darkPrimaryLight,
      secondary: accent,
      surface: darkSurface,
      background: darkBackground,
      error: darkError,
      onPrimary: darkBackground,
      onSecondary: darkTextPrimary,
      onSurface: darkTextPrimary,
      onError: white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkPrimaryDarker, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkPrimary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: darkTextHint, fontSize: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: darkBackground,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkPrimary,
      foregroundColor: darkBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: darkPrimary,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: _buildTextTheme(darkTextPrimary, darkTextSecondary),
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary, letterSpacing: -1, height: 1.2),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.3, height: 1.3),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary, height: 1.4),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.1, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: primary, letterSpacing: 0.15, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: primary, letterSpacing: 0.25, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: secondary, letterSpacing: 0.4, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.1, height: 1.4),
    );
  }

  /// Get order status color
  static Color getOrderStatusColor(String status, bool isDark) {
    final statusKey = status.toLowerCase();
    if (isDark) {
      return darkOrderStatusColors[statusKey] ?? darkTextSecondary;
    }
    return orderStatusColors[statusKey] ?? textSecondary;
  }

  /// Get order status background color
  static Color getOrderStatusBgColor(String status, bool isDark) {
    final color = getOrderStatusColor(status, isDark);
    return color.withAlpha(25);
  } 
}

class AppThemeColors {
  final bool isDark;
  AppThemeColors._(this.isDark);

  Color get primary => isDark ? AppTheme.darkPrimary : AppTheme.primary;
  Color get primaryLight => isDark ? AppTheme.darkPrimaryLight : AppTheme.primaryLight;
  Color get background => isDark ? AppTheme.darkBackground : AppTheme.lightBg;
  Color get surface => isDark ? AppTheme.darkSurface : AppTheme.white;
  Color get textPrimary => isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
  Color get textSecondary => isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
  Color get success => isDark ? AppTheme.darkSuccess : AppTheme.success;
  Color get error => isDark ? AppTheme.darkError : AppTheme.error;
  Color get warning => isDark ? AppTheme.darkWarning : AppTheme.warning;
  Color get info => isDark ? AppTheme.darkInfo : AppTheme.info;

  Color getOrderStatusColor(String status) => AppTheme.getOrderStatusColor(status, isDark);
  Color getOrderStatusBgColor(String status) => AppTheme.getOrderStatusBgColor(status, isDark);
}