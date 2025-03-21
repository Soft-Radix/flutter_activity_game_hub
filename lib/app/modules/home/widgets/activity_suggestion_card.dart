import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../modules/random_picker/controllers/random_picker_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/shadow_utils.dart';
import '../../../widgets/dark_mode_check.dart';

class ActivitySuggestionCard extends GetView<RandomPickerController> {
  const ActivitySuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DarkModeCheck(
      builder: (context, isDarkMode) {
        final greeting = _getTimeBasedGreeting();

        return Card(
          elevation:
              isDarkMode
                  ? AppTheme.mediumElevation
                  : 0, // No elevation in light mode, we'll use shadow instead
          color: context.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
            side: isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              color: isDarkMode ? null : Colors.white,
              boxShadow:
                  isDarkMode
                      ? []
                      : ShadowUtils.getLightModeCardShadow(
                        opacity: 0.15,
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Activity Hub',
                  style: textTheme.displaySmall?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'How are you feeling today?',
                  style: textTheme.titleMedium?.copyWith(
                    color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(AppTheme.padding),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow:
                        isDarkMode
                            ? []
                            : ShadowUtils.getSubtleShadow(
                              opacity: 0.06,
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sentiment_very_satisfied_rounded,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _getWelcomeMessage(context),
                              style: textTheme.bodyLarge?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                height: 1.5,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          // Navigate to team-building activities
                          final teamBuildingCategory =
                              controller.availableGames
                                  .where((game) => game.category == 'team-building')
                                  .toList();

                          if (teamBuildingCategory.isNotEmpty) {
                            controller.updateGames(teamBuildingCategory);
                            Get.toNamed(AppRoutes.CATEGORIES);
                          } else {
                            Get.snackbar(
                              'No Games Available',
                              'No team-building games found',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: context.cardColor,
                              colorText: context.textColor,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius / 2),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? colorScheme.primary.withOpacity(0.2)
                                    : colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius / 2),
                            boxShadow:
                                isDarkMode
                                    ? []
                                    : ShadowUtils.getColoredShadow(
                                      color: colorScheme.primary,
                                      opacity: 0.15,
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                    ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                size: 20,
                                color: isDarkMode ? Colors.white : colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Explore team-building activities!',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : colorScheme.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Get a time-based greeting
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅 Good morning!';
    } else if (hour < 17) {
      return '☀️ Good afternoon!';
    } else if (hour < 21) {
      return '🌆 Good evening!';
    } else {
      return '✨ Hello there!';
    }
  }

  // Get a welcome message with interesting content
  String _getWelcomeMessage(BuildContext context) {
    // A collection of concise, interesting messages
    final messages = [
      "Ready for a quick team activity? We have options for 5, 15, or 30-minute sessions to fit your schedule.",
      "Need to boost team energy? Try an icebreaker or a quick brain teaser from our collection.",
      "Looking for remote-friendly activities? We have virtual options that work great for distributed teams.",
      "Want to improve team communication? Our collaborative challenges can help break down barriers.",
      "Feeling creative today? Check out our problem-solving activities that encourage innovative thinking.",
    ];

    // Return a random message based on the current time
    return messages[DateTime.now().minute % messages.length];
  }

  // Build setup prompt for when no content is available
  Widget _buildSetupPrompt(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 32),
          const SizedBox(height: 16),
          Text(
            'Welcome to Activity Hub',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Find and play fun activities designed to improve team collaboration, problem-solving, and creativity.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                height: 1.5,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 1,
            color:
                isDarkMode
                    ? Colors.grey.shade700.withOpacity(0.5)
                    : Colors.grey.shade300.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Enjoy exploring activities!',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
