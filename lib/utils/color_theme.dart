import 'package:flutter/material.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();
  static AppThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppThemeColors._(isDark);
  }
  
  // ============ LIGHT MODE COLORS ============
  
  // Primary Brand Colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F6B);
  static const Color primaryLighter = Color(0xFFFFB299);
  static const Color primaryDark = Color(0xFFE85A28);
  static const Color primaryDarker = Color(0xFFCC4A1A);
  
  // Secondary Colors - Teal
  static const Color secondary = Color(0xFF2A9D8F);
  static const Color secondaryLight = Color(0xFF4DB8AA);
  static const Color secondaryLighter = Color(0xFF7DCBC0);
  static const Color secondaryDark = Color(0xFF1F7A70);
  static const Color secondaryDarker = Color(0xFF16594F);
  
  // Accent Colors - Purple
  static const Color accent = Color(0xFF6A4C93);
  static const Color accentLight = Color(0xFF8B6FB0);
  static const Color accentLighter = Color(0xFFAD92CD);
  static const Color accentDark = Color(0xFF533A73);
  
  // Background & Surface
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFCFCFC);
  
  // Text Field
  static const Color textfield = Color(0xFFF8F8F8);
  static const Color textfieldFocused = Color(0xFFFFF5F0);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFE0E0E0);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successBackground = Color(0xFFE8F5E9);
  
  static const Color error = Color(0xFFE63946);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);
  static const Color errorBackground = Color(0xFFFFEBEE);
  
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningBackground = Color(0xFFFFF3E0);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoBackground = Color(0xFFE3F2FD);
  
  // Order Status Colors
  static const Color orderPending = Color(0xFFFFA726);
  static const Color orderPendingBg = Color(0xFFFFF8E1);
  static const Color orderConfirmed = Color(0xFF42A5F5);
  static const Color orderConfirmedBg = Color(0xFFE3F2FD);
  static const Color orderPreparing = Color(0xFF7E57C2);
  static const Color orderPreparingBg = Color(0xFFF3E5F5);
  static const Color orderReady = Color(0xFF26A69A);
  static const Color orderReadyBg = Color(0xFFE0F2F1);
  static const Color orderPickedUp = Color(0xFF5C6BC0);
  static const Color orderPickedUpBg = Color(0xFFE8EAF6);
  static const Color orderDelivering = Color(0xFFFF7043);
  static const Color orderDeliveringBg = Color(0xFFFBE9E7);
  static const Color orderCompleted = Color(0xFF66BB6A);
  static const Color orderCompletedBg = Color(0xFFE8F5E9);
  static const Color orderCancelled = Color(0xFFEF5350);
  static const Color orderCancelledBg = Color(0xFFFFEBEE);
  
  // UI Elements
  static const Color divider = Color(0xFFE8E8E8);
  static const Color dividerLight = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBDBDBD);
  
  // Shadows & Overlays
  static const Color shadow = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowStrong = Color(0x26000000);
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color overlayStrong = Color(0xB3000000);
  
  // Special UI Colors
  static const Color discount = Color(0xFFE91E63);
  static const Color discountBg = Color(0xFFFCE4EC);
  static const Color rating = Color(0xFFFFC107);
  static const Color ratingBg = Color(0xFFFFF9C4);
  static const Color premium = Color(0xFFFFD700);
  static const Color verified = Color(0xFF00C853);
  
  // ============ DARK MODE COLORS ============
  
  // Primary Brand Colors
  static const Color darkPrimary = Color(0xFFFF8F6B);
  static const Color darkPrimaryLight = Color(0xFFFFB299);
  static const Color darkPrimaryLighter = Color(0xFFFFCDB8);
  static const Color darkPrimaryDark = Color(0xFFFF6B35);
  static const Color darkPrimaryDarker = Color(0xFFE85A28);
  
  // Secondary Colors
  static const Color darkSecondary = Color(0xFF4DB8AA);
  static const Color darkSecondaryLight = Color(0xFF7DCBC0);
  static const Color darkSecondaryLighter = Color(0xFF9DD9D0);
  static const Color darkSecondaryDark = Color(0xFF2A9D8F);
  
  // Accent Colors
  static const Color darkAccent = Color(0xFF8B6FB0);
  static const Color darkAccentLight = Color(0xFFAD92CD);
  static const Color darkAccentLighter = Color(0xFFC5AFDC);
  static const Color darkAccentDark = Color(0xFF6A4C93);
  
  // Background & Surface
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF242424);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkCardElevated = Color(0xFF282828);
  
  // Text Field
  static const Color darkTextfield = Color(0xFF242424);
  static const Color darkTextfieldFocused = Color(0xFF2A2420);
  
  // Text Colors
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF858585);
  static const Color darkTextHint = Color(0xFF666666);
  static const Color darkTextDisabled = Color(0xFF4D4D4D);
  
  // Semantic Colors
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkSuccessLight = Color(0xFF81C784);
  static const Color darkSuccessDark = Color(0xFF4CAF50);
  static const Color darkSuccessBackground = Color(0xFF1B3A1F);
  
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkErrorLight = Color(0xFFE57373);
  static const Color darkErrorDark = Color(0xFFE63946);
  static const Color darkErrorBackground = Color(0xFF3A1A1D);
  
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkWarningLight = Color(0xFFFFCC80);
  static const Color darkWarningDark = Color(0xFFFFA726);
  static const Color darkWarningBackground = Color(0xFF3A2D1A);
  
  static const Color darkInfo = Color(0xFF42A5F5);
  static const Color darkInfoLight = Color(0xFF64B5F6);
  static const Color darkInfoDark = Color(0xFF2196F3);
  static const Color darkInfoBackground = Color(0xFF1A2A3A);
  
  // Order Status Colors
  static const Color darkOrderPending = Color(0xFFFFB74D);
  static const Color darkOrderPendingBg = Color(0xFF2D2416);
  static const Color darkOrderConfirmed = Color(0xFF64B5F6);
  static const Color darkOrderConfirmedBg = Color(0xFF1A2433);
  static const Color darkOrderPreparing = Color(0xFF9575CD);
  static const Color darkOrderPreparingBg = Color(0xFF291F33);
  static const Color darkOrderReady = Color(0xFF4DB6AC);
  static const Color darkOrderReadyBg = Color(0xFF1A2D2B);
  static const Color darkOrderPickedUp = Color(0xFF7986CB);
  static const Color darkOrderPickedUpBg = Color(0xFF1F2333);
  static const Color darkOrderDelivering = Color(0xFFFF8A65);
  static const Color darkOrderDeliveringBg = Color(0xFF331F1A);
  static const Color darkOrderCompleted = Color(0xFF81C784);
  static const Color darkOrderCompletedBg = Color(0xFF1E2F20);
  static const Color darkOrderCancelled = Color(0xFFE57373);
  static const Color darkOrderCancelledBg = Color(0xFF331D1F);
  
  // UI Elements
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkDividerLight = Color(0xFF242424);
  static const Color darkBorder = Color(0xFF3D3D3D);
  static const Color darkBorderLight = Color(0xFF2D2D2D);
  static const Color darkBorderDark = Color(0xFF4D4D4D);
  
  // Shadows & Overlays
  static const Color darkShadow = Color(0x40000000);
  static const Color darkShadowMedium = Color(0x66000000);
  static const Color darkShadowStrong = Color(0x80000000);
  static const Color darkOverlay = Color(0xCC000000);
  static const Color darkOverlayLight = Color(0x66000000);
  static const Color darkOverlayStrong = Color(0xE6000000);
  
  // Special UI Colors
  static const Color darkDiscount = Color(0xFFF06292);
  static const Color darkDiscountBg = Color(0xFF331A25);
  static const Color darkRating = Color(0xFFFFD54F);
  static const Color darkRatingBg = Color(0xFF332C1A);
  static const Color darkPremium = Color(0xFFFFE082);
  static const Color darkVerified = Color(0xFF69F0AE);
  
  // ============ GRADIENTS ============
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8F6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFFFF8F6B), Color(0xFFFFB299)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF2A9D8F), Color(0xFF4DB8AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkSecondaryGradient = LinearGradient(
    colors: [Color(0xFF4DB8AA), Color(0xFF7DCBC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============ CHART COLORS ============
  
  static const List<Color> chartColors = [
    Color(0xFFFF6B35), Color(0xFF2A9D8F), Color(0xFF6A4C93), Color(0xFF42A5F5),
    Color(0xFFEC407A), Color(0xFF66BB6A), Color(0xFFFFA726), Color(0xFF7E57C2),
  ];
  
  static const List<Color> darkChartColors = [
    Color(0xFFFF8F6B), Color(0xFF4DB8AA), Color(0xFF8B6FB0), Color(0xFF64B5F6),
    Color(0xFFF06292), Color(0xFF81C784), Color(0xFFFFB74D), Color(0xFF9575CD),
  ];
  
  // ============ THEME DATA ============
  
  static ThemeData get light => _buildLightTheme();
  static ThemeData get dark => _buildDarkTheme();
  
  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: primaryLight,
        secondary: secondary,
        secondaryContainer: secondaryLight,
        tertiary: accent,
        tertiaryContainer: accentLight,
        surface: surface,
        surfaceContainerHighest: cardBackground,
        surfaceVariant: surfaceVariant,
        background: background,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
        outline: border,
        outlineVariant: borderLight,
        shadow: shadow,
      ),
      
      scaffoldBackgroundColor: background,
      
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
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
      
      // cardTheme: CardTheme(
      //   color: cardBackground,
      //   surfaceTintColor: Colors.transparent,
      //   elevation: 0,
      //   shadowColor: shadow,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //     side: BorderSide(color: borderLight, width: 1),
      //   ),
      //   margin: EdgeInsets.all(8),
      // ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: textfield,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: textHint, fontSize: 15),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      textTheme: _buildTextTheme(textPrimary, textSecondary),
    );
  }
  
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: darkPrimaryDark,
        secondary: darkSecondary,
        secondaryContainer: darkSecondaryDark,
        tertiary: darkAccent,
        tertiaryContainer: darkAccentDark,
        surface: darkSurface,
        surfaceContainerHighest: darkCardBackground,
        surfaceVariant: darkSurfaceVariant,
        background: darkBackground,
        error: darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.white,
        outline: darkBorder,
        outlineVariant: darkBorderLight,
        shadow: darkShadow,
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
      
      // cardTheme: CardTheme(
      //   color: darkCardBackground,
      //   surfaceTintColor: Colors.transparent,
      //   elevation: 0,
      //   shadowColor: darkShadow,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //     side: BorderSide(color: darkBorderLight, width: 1),
      //   ),
      //   margin: EdgeInsets.all(8),
      // ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkTextfield,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkError, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: darkTextHint, fontSize: 15),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
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
  }
  
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
  
  // ============ HELPER METHODS ============
  
  /// Get order status color
  static Color getOrderStatusColor(String status, bool isDark) {
    final statusMap = {
      'pending': isDark ? darkOrderPending : orderPending,
      'confirmed': isDark ? darkOrderConfirmed : orderConfirmed,
      'preparing': isDark ? darkOrderPreparing : orderPreparing,
      'cooking': isDark ? darkOrderPreparing : orderPreparing,
      'ready': isDark ? darkOrderReady : orderReady,
      'picked up': isDark ? darkOrderPickedUp : orderPickedUp,
      'delivering': isDark ? darkOrderDelivering : orderDelivering,
      'completed': isDark ? darkOrderCompleted : orderCompleted,
      'delivered': isDark ? darkOrderCompleted : orderCompleted,
      'cancelled': isDark ? darkOrderCancelled : orderCancelled,
    };
    return statusMap[status.toLowerCase()] ?? (isDark ? darkTextSecondary : textSecondary);
  }
  
  /// Get order status background color
  static Color getOrderStatusBgColor(String status, bool isDark) {
    final statusMap = {
      'pending': isDark ? darkOrderPendingBg : orderPendingBg,
      'confirmed': isDark ? darkOrderConfirmedBg : orderConfirmedBg,
      'preparing': isDark ? darkOrderPreparingBg : orderPreparingBg,
      'cooking': isDark ? darkOrderPreparingBg : orderPreparingBg,
      'ready': isDark ? darkOrderReadyBg : orderReadyBg,
      'picked up': isDark ? darkOrderPickedUpBg : orderPickedUpBg,
      'delivering': isDark ? darkOrderDeliveringBg : orderDeliveringBg,
      'completed': isDark ? darkOrderCompletedBg : orderCompletedBg,
      'delivered': isDark ? darkOrderCompletedBg : orderCompletedBg,
      'cancelled': isDark ? darkOrderCancelledBg : orderCancelledBg,
    };
    return statusMap[status.toLowerCase()] ?? (isDark ? darkSurfaceVariant : surfaceVariant);
  }
}

// ============ INTERNAL HELPER CLASS ============

class AppThemeColors {
  final bool isDark;
  AppThemeColors._(this.isDark);
  
  Color get primary => isDark ? AppTheme.darkPrimary : AppTheme.primary;
  Color get primaryLight => isDark ? AppTheme.darkPrimaryLight : AppTheme.primaryLight;
  Color get secondary => isDark ? AppTheme.darkSecondary : AppTheme.secondary;
  Color get accent => isDark ? AppTheme.darkAccent : AppTheme.accent;
  Color get background => isDark ? AppTheme.darkBackground : AppTheme.background;
  Color get surface => isDark ? AppTheme.darkSurface : AppTheme.surface;
  Color get textPrimary => isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
  Color get textSecondary => isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
  Color get success => isDark ? AppTheme.darkSuccess : AppTheme.success;
  Color get error => isDark ? AppTheme.darkError : AppTheme.error;
  Color get warning => isDark ? AppTheme.darkWarning : AppTheme.warning;
  
  Color getOrderStatusColor(String status) => AppTheme.getOrderStatusColor(status, isDark);
  Color getOrderStatusBgColor(String status) => AppTheme.getOrderStatusBgColor(status, isDark);
}