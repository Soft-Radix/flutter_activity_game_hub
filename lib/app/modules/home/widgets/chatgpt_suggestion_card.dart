import 'package:flutter/material.dart';

import '../../../themes/app_theme.dart';

class ChatGptSuggestionCard extends StatelessWidget {
  final String suggestion;
  final VoidCallback onRefresh;
  final VoidCallback onSearch;

  const ChatGptSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onRefresh,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        side: const BorderSide(color: AppTheme.secondaryColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('Game Suggestion', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: onRefresh,
                      tooltip: 'Get a new suggestion',
                      color: AppTheme.primaryColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: onSearch,
                      tooltip: 'Search for specific games',
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            suggestion.isEmpty
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.padding),
                    child: CircularProgressIndicator(),
                  ),
                )
                : Text(suggestion, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Find More Games'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
