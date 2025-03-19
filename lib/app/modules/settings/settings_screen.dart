import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';
import '../../themes/app_theme.dart';
import '../../widgets/theme_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: textTheme.headlineSmall),
        centerTitle: true,
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      body: Obx(() {
        final isDarkMode = themeController.isDarkMode;

        return ListView(
          padding: const EdgeInsets.all(AppTheme.padding),
          children: [
            // Theme Settings Section
            _buildSectionHeader(context, 'Appearance'),

            // Theme Selection
            Card(
              margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
              elevation: AppTheme.smallElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              ),
              child: Column(
                children: [
                  // Light Theme Option
                  RadioListTile<ThemeMode>(
                    title: Row(
                      children: [
                        Icon(
                          Icons.light_mode_rounded,
                          color:
                              isDarkMode ? AppTheme.lightTextColorDarkMode : AppTheme.accentColor,
                        ),
                        const SizedBox(width: 12),
                        Text('Light Theme', style: textTheme.titleMedium),
                      ],
                    ),
                    subtitle: Text('Light backgrounds with dark text', style: textTheme.bodySmall),
                    value: ThemeMode.light,
                    groupValue: themeController.themeMode.value,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeController.setThemeMode(value);
                      }
                    },
                    activeColor: colorScheme.primary,
                    selected: themeController.themeMode.value == ThemeMode.light,
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  ),

                  // Dark Theme Option
                  RadioListTile<ThemeMode>(
                    title: Row(
                      children: [
                        Icon(
                          Icons.dark_mode_rounded,
                          color:
                              isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.lightTextColor,
                        ),
                        const SizedBox(width: 12),
                        Text('Dark Theme', style: textTheme.titleMedium),
                      ],
                    ),
                    subtitle: Text('Dark backgrounds with light text', style: textTheme.bodySmall),
                    value: ThemeMode.dark,
                    groupValue: themeController.themeMode.value,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeController.setThemeMode(value);
                      }
                    },
                    activeColor: colorScheme.primary,
                    selected: themeController.themeMode.value == ThemeMode.dark,
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  ),

                  // System Theme Option
                  RadioListTile<ThemeMode>(
                    title: Row(
                      children: [
                        Icon(
                          Icons.settings_suggest_rounded,
                          color:
                              isDarkMode
                                  ? AppTheme.secondaryColorDarkMode
                                  : AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text('System Default', style: textTheme.titleMedium),
                      ],
                    ),
                    subtitle: Text(
                      'Follows your device theme settings',
                      style: textTheme.bodySmall,
                    ),
                    value: ThemeMode.system,
                    groupValue: themeController.themeMode.value,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeController.setThemeMode(value);
                      }
                    },
                    activeColor: colorScheme.primary,
                    selected: themeController.themeMode.value == ThemeMode.system,
                  ),
                ],
              ),
            ),

            // General Settings Section
            _buildSectionHeader(context, 'General'),

            Card(
              margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
              elevation: AppTheme.smallElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    title: 'Notifications',
                    icon: Icons.notifications_outlined,
                    subtitle: 'Manage notification preferences',
                    onTap: () {
                      Get.snackbar(
                        'Notifications',
                        'Notification settings would be implemented here',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  ),

                  _buildSettingsTile(
                    context,
                    title: 'Data & Storage',
                    icon: Icons.storage_outlined,
                    subtitle: 'Manage app data and storage settings',
                    onTap: () {
                      Get.snackbar(
                        'Data & Storage',
                        'Data and storage settings would be implemented here',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),

            // About Section
            _buildSectionHeader(context, 'About'),

            Card(
              margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
              elevation: AppTheme.smallElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    title: 'App Info',
                    icon: Icons.info_outline,
                    subtitle: 'Version 1.0.0',
                    onTap: () {
                      Get.snackbar(
                        'App Info',
                        'Activity Game Hub v1.0.0',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  ),

                  _buildSettingsTile(
                    context,
                    title: 'Help & Support',
                    icon: Icons.help_outline,
                    subtitle: 'Get help or contact support',
                    onTap: () {
                      Get.snackbar(
                        'Help & Support',
                        'Help and support options would be shown here',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    color: isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  ),

                  _buildSettingsTile(
                    context,
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    subtitle: 'View our privacy policy',
                    onTap: () {
                      Get.snackbar(
                        'Privacy Policy',
                        'Privacy policy would be shown here',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.padding,
        bottom: AppTheme.smallPadding,
        top: AppTheme.padding,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;

      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? AppTheme.lightTextColorDarkMode : AppTheme.lightTextColor,
        ),
        onTap: onTap,
      );
    });
  }
}
