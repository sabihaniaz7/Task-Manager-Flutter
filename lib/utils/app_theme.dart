import 'package:flutter/material.dart';

class AppColors {
  static const List<int> cardPalette = [
    0xFFFFE0E0,
    0xFFD8ECFF,
    0xFFFFF3C4,
    0xFFEAE8FF,
    0xFFDDF5E8,
    0xFFFFEDD8,
    0xFFF0E0FF,
    0xFFD8F5F2,
  ];

  static const lightBg = Color(0xFFF2F3F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF1C1C2E);
  static const lightSecondary = Color(0xFF6B7080);
  static const lightSubtext = Color(0xFF9098A8);
  static const lightDivider = Color(0xFFE4E6EE);

  static const darkBg = Color(0xFF0F0F18);
  static const darkSurface = Color(0xFF1A1A28);
  static const darkPrimary = Color(0xFFF0F0FF);
  static const darkSecondary = Color(0xFFAAABC0);
  static const darkSubtext = Color(0xFF70728A);
  static const darkDivider = Color(0xFF252538);

  static const success = Color(0xFF4CAF82);
  static const danger = Color(0xFFE05555);
  static const warning = Color(0xFFE8A030);

  // ── Text colors that sit ON the card ──────────────────────
  // Since card bg is a light pastel (light mode) or dark tint (dark mode),
  // we use the theme's primary text color — it always contrasts fine.
  static Color titleColor(BuildContext context, bool isCompleted) {
    final theme = Theme.of(context);
    final color = theme.textTheme.titleMedium!.color!;
    return isCompleted ? color.withValues(alpha: 0.45) : color;
  }

  static Color bodyColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Slightly more visible than default bodyMedium on colored cards
    return isDark ? const Color(0xFF9899B8) : const Color(0xFF5A6070);
  }

  static Color dateColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF6870A0) : const Color(0xFF8890A8);
  }

  // use a semi-transparent overlay that always contrasts
  static Color actionBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
  }

  static Color actionIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFBBBDD0) : const Color(0xFF50586A);
  }
}

class AppSizes {
  static const double radiusCard = 18;
  static const double radiusButton = 14;
  static const double radiusSheet = 26;
  static const double radiusSmall = 8;
  static const double radiusChip = 6;

  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 20;
  static const double spacingXXL = 28;

  static const double fontDisplay = 28;
  static const double fontTitle = 16;
  static const double fontBody = 13;
  static const double fontCaption = 12;
  static const double fontLabel = 11;
  static const double fontMicro = 9;

  static const double cardBarWidth = 10;
  static const double cardBarTextSize = 8.5;
  static const double cardPadding = 16;

  static const double iconM = 18;
  static const double iconS = 14;
  static const double iconL = 26;
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    useMaterial3: true,
    fontFamily: 'Georgia',
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.lightPrimary),
    ),
    dividerColor: AppColors.lightDivider,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.w800,
        color: AppColors.lightPrimary,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      titleMedium: TextStyle(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.w700,
        color: AppColors.lightPrimary,
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.w500,
        color: AppColors.lightSecondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: AppSizes.fontLabel,
        fontWeight: FontWeight.w600,
        color: AppColors.lightSubtext,
        letterSpacing: 0.3,
      ),
      labelMedium: TextStyle(
        fontSize: AppSizes.fontLabel,
        fontWeight: FontWeight.w700,
        color: AppColors.lightSubtext,
        letterSpacing: 1.0,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      ),
      margin: EdgeInsets.zero,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.lightPrimary,
      unselectedLabelColor: AppColors.lightSubtext,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      hintStyle: const TextStyle(
        color: AppColors.lightSubtext,
        fontSize: AppSizes.fontBody,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: AppColors.lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingM,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    useMaterial3: true,
    fontFamily: 'Georgia',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.darkPrimary),
    ),
    dividerColor: AppColors.darkDivider,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.w800,
        color: AppColors.darkPrimary,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      titleMedium: TextStyle(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.w700,
        color: AppColors.darkPrimary,
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.w500,
        color: AppColors.darkSecondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: AppSizes.fontLabel,
        fontWeight: FontWeight.w600,
        color: AppColors.darkSubtext,
        letterSpacing: 0.3,
      ),
      labelMedium: TextStyle(
        fontSize: AppSizes.fontLabel,
        fontWeight: FontWeight.w700,
        color: AppColors.darkSubtext,
        letterSpacing: 1.0,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkBg,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      ),
      margin: EdgeInsets.zero,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.darkPrimary,
      unselectedLabelColor: AppColors.darkSubtext,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      hintStyle: const TextStyle(
        color: AppColors.darkSubtext,
        fontSize: AppSizes.fontBody,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: AppColors.darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingM,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
    ),
  );
}

// ── Simple notifier to toggle theme mode ──────────────────
class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
