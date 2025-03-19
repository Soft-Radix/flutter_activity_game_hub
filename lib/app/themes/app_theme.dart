import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Light Mode
  static const Color primaryColor = Color(0xFF4A6FFF);
  static const Color primaryColorLight = Color(0xFF879FFF);
  static const Color primaryColorDark = Color(0xFF3451CC);
  static const Color secondaryColor = Color(0xFF42E2B8);
  static const Color accentColor = Color(0xFFFFA26B);
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF0F3FA);
  static const Color textColor = Color(0xFF2D3142);
  static const Color lightTextColor = Color(0xFF9297A7);
  static const Color errorColor = Color(0xFFE94F37);
  static const Color successColor = Color(0xFF36B37E);
  static const Color warningColor = Color(0xFFFFAB00);
  static const Color infoColor = Color(0xFF2684FF);

  // Colors - Dark Mode
  static const Color primaryColorDarkMode = Color(0xFF78A9FF);
  static const Color secondaryColorDarkMode = Color(0xFF4CEAC0);
  static const Color accentColorDarkMode = Color(0xFFFFB685);
  static const Color backgroundColorDarkMode = Color(0xFF1A1C2A);
  static const Color cardColorDarkMode = Color(0xFF2D3142);
  static const Color surfaceColorDarkMode = Color(0xFF242736);
  static const Color textColorDarkMode = Color(0xFFF0F3FA);
  static const Color lightTextColorDarkMode = Color(0xFFB4B8C5);

  // Category colors
  static const Color icebreakersColor = Color(0xFF00BCD4);
  static const Color teamBuildingColor = Color(0xFF4CAF50);
  static const Color brainGamesColor = Color(0xFF9C27B0);
  static const Color quickGamesColor = Color(0xFFFF9800);

  // Dimensions
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 12.0;
  static const double cardBorderRadius = 20.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Elevation
  static const double smallElevation = 1.0;
  static const double defaultElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double largeElevation = 8.0;

  // Get Light Theme Data
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardBorderRadius)),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.all(smallPadding),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        iconTheme: const IconThemeData(color: textColor),
        actionsIconTheme: const IconThemeData(color: primaryColor),
        scrolledUnderElevation: defaultElevation,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: -0.25,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.25,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textColor, height: 1.5),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textColor, height: 1.5),
        bodySmall: GoogleFonts.poppins(fontSize: 12, color: lightTextColor, height: 1.5),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: mediumElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        splashColor: Colors.white.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: smallElevation,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: lightTextColor),
        errorStyle: GoogleFonts.poppins(fontSize: 12, color: errorColor),
        prefixIconColor: primaryColor,
        suffixIconColor: lightTextColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: mediumElevation,
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return lightTextColor;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return lightTextColor;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(smallBorderRadius / 2)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        disabledColor: surfaceColor.withOpacity(0.5),
        selectedColor: primaryColor.withOpacity(0.2),
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.all(mediumPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(smallBorderRadius)),
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: textColor),
        secondaryLabelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        brightness: Brightness.light,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardColor,
        elevation: largeElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardBorderRadius)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        elevation: largeElevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(cardBorderRadius),
            topRight: Radius.circular(cardBorderRadius),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.withOpacity(0.2),
        thickness: 1,
        space: largePadding,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(smallBorderRadius),
        ),
        textStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColorDarkMode,
        contentTextStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(smallBorderRadius)),
        behavior: SnackBarBehavior.floating,
        actionTextColor: secondaryColor,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: smallPadding),
        minLeadingWidth: 24,
        minVerticalPadding: mediumPadding,
        iconColor: primaryColor,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: lightTextColor,
        labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(width: 3, color: primaryColor),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceColor,
        circularTrackColor: surfaceColor,
      ),
    );
  }

  // Get Dark Theme Data
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColorDarkMode,
        primary: primaryColorDarkMode,
        secondary: secondaryColorDarkMode,
        tertiary: accentColorDarkMode,
        error: errorColor,
        background: backgroundColorDarkMode,
        surface: surfaceColorDarkMode,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColorDarkMode,
      cardTheme: CardTheme(
        color: cardColorDarkMode,
        elevation: defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardBorderRadius)),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
        margin: const EdgeInsets.all(smallPadding),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColorDarkMode,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColorDarkMode,
        ),
        iconTheme: IconThemeData(color: textColorDarkMode),
        actionsIconTheme: const IconThemeData(color: primaryColorDarkMode),
        scrolledUnderElevation: defaultElevation,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColorDarkMode,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColorDarkMode,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColorDarkMode,
          letterSpacing: -0.25,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColorDarkMode,
          letterSpacing: -0.25,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColorDarkMode,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColorDarkMode,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColorDarkMode,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColorDarkMode,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textColorDarkMode, height: 1.5),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textColorDarkMode, height: 1.5),
        bodySmall: GoogleFonts.poppins(fontSize: 12, color: lightTextColorDarkMode, height: 1.5),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColorDarkMode,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColorDarkMode,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColorDarkMode,
        foregroundColor: textColorDarkMode,
        elevation: mediumElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        splashColor: Colors.white.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: smallElevation,
          backgroundColor: primaryColorDarkMode,
          foregroundColor: textColorDarkMode,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColorDarkMode,
          side: BorderSide(color: primaryColorDarkMode, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColorDarkMode,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColorDarkMode,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColorDarkMode, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: lightTextColorDarkMode),
        errorStyle: GoogleFonts.poppins(fontSize: 12, color: errorColor),
        prefixIconColor: primaryColorDarkMode,
        suffixIconColor: lightTextColorDarkMode,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColorDarkMode,
        selectedItemColor: primaryColorDarkMode,
        unselectedItemColor: lightTextColorDarkMode,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: mediumElevation,
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColorDarkMode;
          }
          return lightTextColorDarkMode;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColorDarkMode;
          }
          return lightTextColorDarkMode;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(smallBorderRadius / 2)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColorDarkMode,
        disabledColor: surfaceColorDarkMode.withOpacity(0.5),
        selectedColor: primaryColorDarkMode.withOpacity(0.2),
        secondarySelectedColor: primaryColorDarkMode,
        padding: const EdgeInsets.all(mediumPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(smallBorderRadius)),
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: textColorDarkMode),
        secondaryLabelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        brightness: Brightness.dark,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardColorDarkMode,
        elevation: largeElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardBorderRadius)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColorDarkMode,
        elevation: largeElevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(cardBorderRadius),
            topRight: Radius.circular(cardBorderRadius),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.withOpacity(0.3),
        thickness: 1,
        space: largePadding,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textColorDarkMode.withOpacity(0.9),
          borderRadius: BorderRadius.circular(smallBorderRadius),
        ),
        textStyle: GoogleFonts.poppins(fontSize: 12, color: backgroundColorDarkMode),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColorDarkMode,
        contentTextStyle: GoogleFonts.poppins(fontSize: 14, color: textColorDarkMode),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(smallBorderRadius)),
        behavior: SnackBarBehavior.floating,
        actionTextColor: secondaryColorDarkMode,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: smallPadding),
        minLeadingWidth: 24,
        minVerticalPadding: mediumPadding,
        iconColor: primaryColorDarkMode,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColorDarkMode,
        unselectedLabelColor: lightTextColorDarkMode,
        labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3, color: primaryColorDarkMode),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColorDarkMode,
        linearTrackColor: surfaceColorDarkMode,
        circularTrackColor: surfaceColorDarkMode,
      ),
    );
  }

  // Helper method to get theme based on brightness
  static ThemeData getTheme({Brightness brightness = Brightness.light}) {
    return brightness == Brightness.light ? getLightTheme() : getDarkTheme();
  }
}
