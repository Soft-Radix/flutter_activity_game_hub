import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/chatgpt_game_card.dart';

class ChatGptSuggestionCard extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onSearch;

  const ChatGptSuggestionCard({super.key, required this.onRefresh, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final colorScheme = Theme.of(context).colorScheme;
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final suggestion = appController.currentGameSuggestion.value;
      final isDarkMode = themeController.isDarkMode;

      if (suggestion == null) {
        return Card(
          elevation: 4.0,
          shadowColor: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color:
                      isDarkMode ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
          ),
        );
      }

      return ChatGptGameCard(suggestion: suggestion, onRefresh: onRefresh, onSearch: onSearch);
    });
  }
}
