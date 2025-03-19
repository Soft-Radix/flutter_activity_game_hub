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
  }

  /// Initialize Hive for theme persistence
  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_themeBoxName)) {
      _themeBox = await Hive.openBox(_themeBoxName);
    } else {
      _themeBox = Hive.box(_themeBoxName);
    }
  }

  /// Load saved theme mode from storage
  void _loadThemeMode() {
    final savedThemeMode = _themeBox.get(_themeModeKey);
    if (savedThemeMode != null) {
      themeMode.value = ThemeMode.values[savedThemeMode];
    } else {
      // Set default theme based on system brightness if not previously set
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      themeMode.value = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
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
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _saveThemeMode();
  }

  /// Save current theme mode to storage
  void _saveThemeMode() {
    _themeBox.put(_themeModeKey, themeMode.value.index);
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
