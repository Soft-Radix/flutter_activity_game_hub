import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Controller to manage app theme settings
class ThemeController extends GetxController {
  static const String _themeBoxName = 'theme_box';
  static const String _themeModeKey = 'theme_mode';

  late Box _themeBox;

  // Observable theme mode with light mode as default
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() async {
    super.onInit();
    await _initHive();
    _loadThemeMode();

    // Listen to themeMode changes and update GetX theme
    ever(themeMode, (_) {
      Get.changeThemeMode(themeMode.value);
      update(); // Force update of all GetBuilder widgets
    });
  }

  /// Initialize Hive for theme persistence
  Future<void> _initHive() async {
    try {
      if (!Hive.isBoxOpen(_themeBoxName)) {
        _themeBox = await Hive.openBox(_themeBoxName);
      } else {
        _themeBox = Hive.box(_themeBoxName);
      }
      debugPrint('✅ Theme box initialized successfully: ${_themeBox.name}');
    } catch (e) {
      debugPrint('❌ Error initializing theme box: $e');
      // Create a temporary in-memory box if storage access fails
      _themeBox = await Hive.openBox(
        _themeBoxName,
        crashRecovery: true,
        compactionStrategy: (entries, deletedEntries) => deletedEntries > 10,
      );
    }
  }

  /// Load saved theme mode from storage
  void _loadThemeMode() {
    try {
      final savedThemeMode = _themeBox.get(_themeModeKey);
      if (savedThemeMode != null) {
        final mode = ThemeMode.values[savedThemeMode];
        themeMode.value = mode;
        debugPrint('✅ Loaded theme mode from storage: $mode');
      } else {
        // Set default theme based on system brightness if not previously set
        final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
        final defaultMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
        themeMode.value = defaultMode;
        debugPrint('ℹ️ No saved theme found. Using system default: $defaultMode');
      }

      // Apply theme mode immediately
      Get.changeThemeMode(themeMode.value);
    } catch (e) {
      debugPrint('❌ Error loading theme mode: $e');
      // Default to system in case of error
      themeMode.value = ThemeMode.system;
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    if (themeMode.value == ThemeMode.system) {
      // If system, check current brightness and toggle to the opposite
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      themeMode.value = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      // Otherwise just toggle between light and dark
      themeMode.value = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
    _saveThemeMode();

    debugPrint('🎨 Theme toggled to: ${themeMode.value}');
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    if (themeMode.value == mode) return; // No change needed

    themeMode.value = mode;
    _saveThemeMode();

    debugPrint('🎨 Theme mode set to: $mode');
  }

  /// Save current theme mode to storage
  void _saveThemeMode() {
    try {
      _themeBox.put(_themeModeKey, themeMode.value.index);
      debugPrint('✅ Theme mode saved to storage: ${themeMode.value}');
    } catch (e) {
      debugPrint('❌ Error saving theme mode: $e');
    }
  }

  /// Check if dark mode is currently active
  bool get isDarkMode {
    if (themeMode.value == ThemeMode.system) {
      // For system mode, return actual system dark mode status
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  /// Get the current brightness of the app
  Brightness get currentBrightness => isDarkMode ? Brightness.dark : Brightness.light;
}
