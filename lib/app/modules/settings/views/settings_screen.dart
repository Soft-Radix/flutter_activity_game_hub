import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/theme_controller.dart';
import '../../../data/services/api_config.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/dark_mode_check.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
              title: Text(
                'Settings',
                style: textTheme.headlineSmall?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: const [SizedBox(width: 8)],
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppTheme.padding),
              children: [
                // Theme Settings Section
                _buildSectionHeader(context, 'Appearance', isDarkMode),

                // Theme Selection
                Card(
                  color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                  margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
                  elevation: isDarkMode ? 4.0 : AppTheme.smallElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                    side:
                        isDarkMode
                            ? BorderSide(color: Colors.grey.shade800, width: 1)
                            : BorderSide.none,
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
                                  isDarkMode
                                      ? AppTheme.lightTextColorDarkMode
                                      : AppTheme.accentColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Light Theme',
                              style: textTheme.titleMedium?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Light backgrounds with dark text',
                          style: textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        value: ThemeMode.light,
                        groupValue: themeController.themeMode.value,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeController.setThemeMode(value);
                          }
                        },
                        activeColor: isDarkMode ? AppTheme.primaryColorLight : colorScheme.primary,
                        selected: themeController.themeMode.value == ThemeMode.light,
                      ),

                      Divider(
                        indent: 20,
                        endIndent: 20,
                        color:
                            isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                      ),

                      // Dark Theme Option
                      RadioListTile<ThemeMode>(
                        title: Row(
                          children: [
                            Icon(
                              Icons.dark_mode_rounded,
                              color:
                                  isDarkMode ? AppTheme.primaryColorLight : AppTheme.lightTextColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Dark Theme',
                              style: textTheme.titleMedium?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Dark backgrounds with light text',
                          style: textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        value: ThemeMode.dark,
                        groupValue: themeController.themeMode.value,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeController.setThemeMode(value);
                          }
                        },
                        activeColor: isDarkMode ? AppTheme.primaryColorLight : colorScheme.primary,
                        selected: themeController.themeMode.value == ThemeMode.dark,
                      ),

                      Divider(
                        indent: 20,
                        endIndent: 20,
                        color:
                            isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
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
                            Text(
                              'System Default',
                              style: textTheme.titleMedium?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Follows your device theme settings',
                          style: textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        value: ThemeMode.system,
                        groupValue: themeController.themeMode.value,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeController.setThemeMode(value);
                          }
                        },
                        activeColor: isDarkMode ? AppTheme.primaryColorLight : colorScheme.primary,
                        selected: themeController.themeMode.value == ThemeMode.system,
                      ),
                    ],
                  ),
                ),

                // General Settings Section
                _buildSectionHeader(context, 'General', isDarkMode),

                Card(
                  color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                  margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
                  elevation: isDarkMode ? 4.0 : AppTheme.smallElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                    side:
                        isDarkMode
                            ? BorderSide(color: Colors.grey.shade800, width: 1)
                            : BorderSide.none,
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
                            backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                            colorText: isDarkMode ? Colors.white : Colors.black87,
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),

                      Divider(
                        indent: 20,
                        endIndent: 20,
                        color:
                            isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
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
                            backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                            colorText: isDarkMode ? Colors.white : Colors.black87,
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),

                // About Section
                _buildSectionHeader(context, 'About', isDarkMode),

                Card(
                  color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                  margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
                  elevation: isDarkMode ? 4.0 : AppTheme.smallElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                    side:
                        isDarkMode
                            ? BorderSide(color: Colors.grey.shade800, width: 1)
                            : BorderSide.none,
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
                            backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                            colorText: isDarkMode ? Colors.white : Colors.black87,
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),

                      Divider(
                        indent: 20,
                        endIndent: 20,
                        color:
                            isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
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
                            backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                            colorText: isDarkMode ? Colors.white : Colors.black87,
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),

                      Divider(
                        indent: 20,
                        endIndent: 20,
                        color:
                            isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
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
                            backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                            colorText: isDarkMode ? Colors.white : Colors.black87,
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),

                _buildApiSettings(isDarkMode),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppTheme.primaryColorLight : AppTheme.primaryColor,
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
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? AppTheme.primaryColorLight.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDarkMode ? AppTheme.primaryColorLight : AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: isDarkMode ? Colors.white : Colors.black87),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.white70 : Colors.black54),
      ),
      trailing: Icon(Icons.chevron_right, color: isDarkMode ? Colors.white70 : Colors.black54),
      onTap: onTap,
    );
  }

  Widget _buildApiSettings(bool isDarkMode) {
    final TextEditingController apiKeyController = TextEditingController();

    // Load the saved API key if available
    ApiConfig.getGeminiApiKey().then((value) {
      if (value != "YOUR_GEMINI_API_KEY") {
        apiKeyController.text = value;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? const Color(0xFF5C6BC0).withOpacity(0.2)
                    : Get.theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border:
                isDarkMode
                    ? Border.all(color: const Color(0xFF5C6BC0).withOpacity(0.4), width: 1)
                    : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.api,
                color: isDarkMode ? const Color(0xFF5C6BC0) : Get.theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                'API Settings',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Gemini API Key',
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: apiKeyController,
            decoration: InputDecoration(
              hintText: 'Enter your Gemini API key',
              hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode ? const Color(0xFF5C6BC0) : AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.save,
                  color: isDarkMode ? const Color(0xFF5C6BC0) : AppTheme.primaryColor,
                ),
                onPressed: () async {
                  final apiKey = apiKeyController.text.trim();
                  if (apiKey.isNotEmpty) {
                    await ApiConfig.setGeminiApiKey(apiKey);
                    Get.snackbar(
                      'Success',
                      'API key saved successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
            ),
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            obscureText: true, // Hide the API key
            enableSuggestions: false,
            autocorrect: false,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'This API key is used to fetch game data from the Gemini API.',
            style: Get.textTheme.bodySmall?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: isDarkMode ? Colors.grey.shade800 : Get.theme.dividerColor),
      ],
    );
  }
}
