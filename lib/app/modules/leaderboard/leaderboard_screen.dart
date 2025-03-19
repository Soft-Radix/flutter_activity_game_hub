import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../controllers/leaderboard_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../data/models/leaderboard_entry_model.dart';
import '../../themes/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final themeController = Get.find<ThemeController>();
    final leaderboardController = Get.find<LeaderboardController>();
    final colorScheme = Theme.of(context).colorScheme;

    // Check if a specific game filter was provided
    Map<String, dynamic>? args;
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      args = Get.arguments as Map<String, dynamic>;
    }

    final isGameSpecific = args != null && args.containsKey('gameId');
    final gameId = isGameSpecific ? args['gameId'] as String : null;

    // If game specific, get entries for that game
    final List<LeaderboardEntry> gameEntries =
        gameId != null ? leaderboardController.getTopEntriesForGame(gameId) : <LeaderboardEntry>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGameSpecific ? 'Game Leaderboard' : 'Leaderboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading:
            isGameSpecific
                ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back())
                : null,
      ),
      body:
          isGameSpecific
              ? _buildGameSpecificLeaderboard(context, gameEntries)
              : _buildGlobalLeaderboard(context, leaderboardController),
    );
  }

  Widget _buildGlobalLeaderboard(BuildContext context, LeaderboardController controller) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;

      return Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.all(AppTheme.padding),
            color: isDarkMode ? AppTheme.cardColorDarkMode : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View top players across all games',
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Filter chips
                Obx(
                  () => Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'All Time',
                        isSelected: controller.currentFilter.value == 'all',
                        onSelected: (_) => controller.applyFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'This Week',
                        isSelected: controller.currentFilter.value == 'week',
                        onSelected: (_) => controller.applyFilter('week'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'This Month',
                        isSelected: controller.currentFilter.value == 'month',
                        onSelected: (_) => controller.applyFilter('month'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard entries list
          Expanded(
            child: Obx(
              () =>
                  controller.isLoading.value
                      ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                      : controller.filteredEntries.isEmpty
                      ? _buildEmptyLeaderboard(context)
                      : _buildLeaderboardList(context, controller),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGameSpecificLeaderboard(BuildContext context, List<LeaderboardEntry> entries) {
    final themeController = Get.find<ThemeController>();
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;

      return entries.isEmpty
          ? _buildEmptyLeaderboard(context)
          : Column(
            children: [
              if (entries.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppTheme.padding),
                  color: isDarkMode ? AppTheme.cardColorDarkMode : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entries.first.gameName,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Top scores for this game',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: _buildLeaderboardEntries(context, entries)),
            ],
          );
    });
  }

  Widget _buildLeaderboardList(BuildContext context, LeaderboardController controller) {
    // Get the top players (name + highest score)
    final topPlayers = controller.getTopPlayersOrTeams();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: AppTheme.padding, bottom: AppTheme.padding),
          itemCount: topPlayers.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildPlayerCard(
                    context,
                    name: topPlayers[index]['name'] as String,
                    score: topPlayers[index]['score'] as int,
                    rank: index + 1,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntries(BuildContext context, List<LeaderboardEntry> entries) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: AppTheme.padding, bottom: AppTheme.padding),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildPlayerCard(
                    context,
                    name: entry.playerOrTeamName,
                    score: entry.score,
                    rank: index + 1,
                    date: entry.datePlayed,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
    BuildContext context, {
    required String name,
    required int score,
    required int rank,
    DateTime? date,
  }) {
    final themeController = Get.find<ThemeController>();
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;
      final Color cardColor = isDarkMode ? AppTheme.cardColorDarkMode : Colors.white;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3.0,
        shadowColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.padding),
          child: Row(
            children: [
              // Rank circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getRankColor(rank).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Player name and score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppTheme.textColor,
                      ),
                    ),
                    if (date != null)
                      Text(
                        'Date: ${_formatDate(date)}',
                        style: textTheme.bodySmall?.copyWith(
                          color:
                              isDarkMode
                                  ? AppTheme.lightTextColorDarkMode.withOpacity(0.9)
                                  : AppTheme.lightTextColor,
                        ),
                      ),
                  ],
                ),
              ),

              // Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? _getRankColor(rank).withOpacity(0.25)
                          : _getRankColor(rank).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getRankColor(rank).withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '$score points',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? _getRankColor(rank).withOpacity(0.9) : _getRankColor(rank),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;
      final colorScheme = Theme.of(context).colorScheme;

      return Flexible(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(!isSelected),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              splashColor: colorScheme.primary.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? isDarkMode
                              ? colorScheme.primary.withOpacity(0.8)
                              : colorScheme.primary
                          : isDarkMode
                          ? AppTheme.surfaceColorDarkMode
                          : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(
                    color:
                        isSelected
                            ? colorScheme.primary
                            : isDarkMode
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(isDarkMode ? 0.3 : 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? isDarkMode
                                  ? Colors.white
                                  : Colors.white
                              : isDarkMode
                              ? AppTheme.textColorDarkMode
                              : AppTheme.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyLeaderboard(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: isDarkMode ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Leaderboard Entries Yet',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Play games and save your scores to see them here',
              style: textTheme.bodyLarge?.copyWith(
                color:
                    isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.primaryColor; // Blue for others
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
