import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import '../themes/app_theme.dart';

/// A widget to toggle between light and dark themes
class ThemeToggle extends StatelessWidget {
  /// Creates a theme toggle widget
  const ThemeToggle({super.key, this.showLabel = false, this.size = 24.0, this.customPosition});

  /// Whether to show a text label beside the toggle
  final bool showLabel;

  /// Size of the toggle icon
  final double size;

  /// Optional custom position for the toggle (e.g., in AppBar actions)
  final Widget? customPosition;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;
      final currentThemeMode = themeController.themeMode.value;

      if (customPosition != null) {
        return customPosition!;
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          onTap: themeController.toggleTheme,
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: AppTheme.shortAnimationDuration,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.padding,
              vertical: AppTheme.smallPadding,
            ),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? AppTheme.surfaceColorDarkMode.withOpacity(0.8)
                      : AppTheme.surfaceColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: AppTheme.shortAnimationDuration,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: _buildThemeIcon(currentThemeMode, isDarkMode, size),
                ),
                if (showLabel) ...[
                  const SizedBox(width: AppTheme.smallPadding),
                  AnimatedSwitcher(
                    duration: AppTheme.shortAnimationDuration,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      _getThemeModeName(currentThemeMode),
                      key: ValueKey<String>(_getThemeModeName(currentThemeMode)),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Build the appropriate icon based on the current theme mode
  Widget _buildThemeIcon(ThemeMode mode, bool isDarkMode, double iconSize) {
    switch (mode) {
      case ThemeMode.light:
        return Icon(
          Icons.light_mode_rounded,
          key: const ValueKey('light_mode'),
          color: AppTheme.accentColor,
          size: iconSize,
        );
      case ThemeMode.dark:
        return Icon(
          Icons.dark_mode_rounded,
          key: const ValueKey('dark_mode'),
          color: AppTheme.primaryColorDarkMode,
          size: iconSize,
        );
      case ThemeMode.system:
        return Icon(
          Icons.brightness_auto_rounded,
          key: const ValueKey('system_mode'),
          color: isDarkMode ? AppTheme.secondaryColorDarkMode : AppTheme.secondaryColor,
          size: iconSize,
        );
    }
  }

  /// Get the display name for the theme mode
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }
}

/// A floating theme toggle button that appears at the bottom of the screen
class FloatingThemeToggle extends StatelessWidget {
  const FloatingThemeToggle({super.key, this.bottomMargin = 80.0, this.rightMargin = 16.0});

  final double bottomMargin;
  final double rightMargin;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: bottomMargin,
      right: rightMargin,
      child: Obx(() {
        final isDarkMode = themeController.isDarkMode;
        final currentThemeMode = themeController.themeMode.value;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: themeController.toggleTheme,
            splashColor: colorScheme.primary.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardColorDarkMode : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: AppTheme.shortAnimationDuration,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _buildFloatingThemeIcon(currentThemeMode, isDarkMode),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFloatingThemeIcon(ThemeMode mode, bool isDarkMode) {
    switch (mode) {
      case ThemeMode.light:
        return const Icon(
          Icons.light_mode_rounded,
          key: ValueKey('float_light_mode'),
          color: AppTheme.accentColor,
          size: 28,
        );
      case ThemeMode.dark:
        return const Icon(
          Icons.dark_mode_rounded,
          key: ValueKey('float_dark_mode'),
          color: AppTheme.primaryColorDarkMode,
          size: 28,
        );
      case ThemeMode.system:
        return Icon(
          Icons.brightness_auto_rounded,
          key: const ValueKey('float_system_mode'),
          color: isDarkMode ? AppTheme.secondaryColorDarkMode : AppTheme.secondaryColor,
          size: 28,
        );
    }
  }
}
