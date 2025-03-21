import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import '../themes/app_theme.dart';

/// Utility functions to ensure consistent theme behavior across the app
class ThemeUtils {
  /// Get the appropriate background color based on current theme
  static Color getBackgroundColor(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return themeController.isDarkMode ? AppTheme.backgroundColorDarkMode : AppTheme.backgroundColor;
  }

  /// Get the appropriate card color based on current theme
  static Color getCardColor(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return themeController.isDarkMode ? AppTheme.cardColorDarkMode : AppTheme.cardColor;
  }

  /// Get the appropriate text color based on current theme
  static Color getTextColor(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return themeController.isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor;
  }

  /// Get the appropriate light text color based on current theme
  static Color getLightTextColor(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return themeController.isDarkMode ? AppTheme.lightTextColorDarkMode : AppTheme.lightTextColor;
  }

  /// Get the appropriate surface color based on current theme
  static Color getSurfaceColor(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return themeController.isDarkMode ? AppTheme.surfaceColorDarkMode : AppTheme.surfaceColor;
  }

  /// Get elevated container decoration based on theme
  static BoxDecoration getElevatedContainerDecoration(
    BuildContext context, {
    double borderRadius = AppTheme.borderRadius,
    double elevation = 4.0,
  }) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode;

    return BoxDecoration(
      color: isDarkMode ? AppTheme.cardColorDarkMode : Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation / 2),
        ),
      ],
      border: isDarkMode ? Border.all(color: Colors.grey.shade800, width: 1) : null,
    );
  }

  /// Create a gradient background based on theme
  static BoxDecoration getGradientBackground(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors:
            isDarkMode
                ? [
                  AppTheme.backgroundColorDarkMode,
                  Color.lerp(
                        AppTheme.backgroundColorDarkMode,
                        AppTheme.primaryColorDarkMode,
                        0.15,
                      ) ??
                      AppTheme.backgroundColorDarkMode,
                ]
                : [
                  AppTheme.backgroundColor,
                  Color.lerp(AppTheme.backgroundColor, AppTheme.primaryColor, 0.12) ??
                      AppTheme.backgroundColor,
                ],
      ),
    );
  }

  /// Get the AppBar theme based on current theme
  static AppBar getThemedAppBar(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
    PreferredSizeWidget? bottom,
    Widget? leading,
  }) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      title: Text(
        title,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : AppTheme.textColor,
        ),
      ),
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDarkMode : AppTheme.backgroundColor,
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
      leading: leading,
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppTheme.textColor),
    );
  }
}
