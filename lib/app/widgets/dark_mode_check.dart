import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

/// A widget that ensures the dark mode is properly applied to its child
/// This can be used to wrap screens or components to ensure they respond to theme changes
class DarkModeCheck extends StatelessWidget {
  const DarkModeCheck({super.key, required this.builder, this.onDarkModeChanged});

  /// Builder function that takes the context and isDarkMode flag
  final Widget Function(BuildContext context, bool isDarkMode) builder;

  /// Optional callback for when dark mode changes
  final Function(bool isDarkMode)? onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    // Use GetX's find with tag to ensure consistent controller instance
    final themeController = Get.find<ThemeController>();

    return GetBuilder<ThemeController>(
      builder: (controller) {
        final isDarkMode = controller.isDarkMode;

        // Call the optional callback if provided
        if (onDarkModeChanged != null) {
          onDarkModeChanged!(isDarkMode);
        }

        debugPrint(
          '🎨 DarkModeCheck builder with isDarkMode: $isDarkMode, theme mode: ${controller.themeMode.value}',
        );

        return builder(context, isDarkMode);
      },
    );
  }
}

/// Extension to provide isDarkMode directly on BuildContext
extension DarkModeContext on BuildContext {
  bool get isDarkMode {
    final themeController = Get.find<ThemeController>();
    return themeController.isDarkMode;
  }

  // Get text color based on current theme
  Color get textColor {
    return isDarkMode ? Colors.white : Colors.black;
  }

  // Get background color based on current theme
  Color get backgroundColor {
    return isDarkMode ? const Color(0xFF1A1C2A) : Colors.white;
  }

  // Get card color based on current theme
  Color get cardColor {
    return isDarkMode ? const Color(0xFF2D3142) : Colors.white;
  }
}
