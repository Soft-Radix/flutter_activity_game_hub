import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../controllers/leaderboard_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/shadow_utils.dart';
import '../../../widgets/dark_mode_check.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final leaderboardController = Get.find<LeaderboardController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: isDarkMode ? const Color(0xFF1A1C2A) : Colors.white,
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
              elevation: isDarkMode ? 0 : 2,
              shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1),
              title: Text(
                isGameSpecific ? 'Game Leaderboard' : 'Leaderboard',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              leading:
                  isGameSpecific
                      ? IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => Get.back(),
                      )
                      : null,
            ),
            body:
                isGameSpecific
                    ? _buildGameSpecificLeaderboard(context, gameEntries, isDarkMode)
                    : _buildGlobalLeaderboard(context, leaderboardController, isDarkMode),
          ),
    );
  }

  Widget _buildGlobalLeaderboard(
    BuildContext context,
    LeaderboardController controller,
    bool isDarkMode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Filter tabs
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.padding,
            vertical: AppTheme.padding,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF252842) : Colors.white,
            boxShadow:
                isDarkMode
                    ? []
                    : ShadowUtils.getSubtleShadow(
                      opacity: 0.08,
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaderboard',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'View top players across all games',
                style: textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // Filter chips
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterChip(
                      context,
                      label: 'All Time',
                      isSelected: controller.currentFilter.value == 'all',
                      onSelected: (_) => controller.applyFilter('all'),
                      isDarkMode: isDarkMode,
                    ),
                    _buildFilterChip(
                      context,
                      label: 'This Week',
                      isSelected: controller.currentFilter.value == 'week',
                      onSelected: (_) => controller.applyFilter('week'),
                      isDarkMode: isDarkMode,
                    ),
                    _buildFilterChip(
                      context,
                      label: 'This Month',
                      isSelected: controller.currentFilter.value == 'month',
                      onSelected: (_) => controller.applyFilter('month'),
                      isDarkMode: isDarkMode,
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
                    ? _buildEmptyLeaderboard(context, isDarkMode)
                    : _buildLeaderboardList(context, controller, isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildGameSpecificLeaderboard(
    BuildContext context,
    List<LeaderboardEntry> entries,
    bool isDarkMode,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return entries.isEmpty
        ? _buildEmptyLeaderboard(context, isDarkMode)
        : Column(
          children: [
            if (entries.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppTheme.padding),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                  boxShadow:
                      isDarkMode
                          ? []
                          : ShadowUtils.getSubtleShadow(
                            opacity: 0.08,
                            spreadRadius: 0,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entries.first.gameName,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Top scores for this game',
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: _buildLeaderboardEntries(context, entries, isDarkMode)),
          ],
        );
  }

  Widget _buildLeaderboardList(
    BuildContext context,
    LeaderboardController controller,
    bool isDarkMode,
  ) {
    // Get the top players (name + highest score)
    final topPlayers = controller.getTopPlayersOrTeams();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
      color: isDarkMode ? const Color(0xFF1A1C2A) : Colors.grey.shade50,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: AppTheme.padding, bottom: AppTheme.padding * 2),
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
                    isDarkMode: isDarkMode,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntries(
    BuildContext context,
    List<LeaderboardEntry> entries,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
      color: isDarkMode ? const Color(0xFF1A1C2A) : Colors.grey.shade50,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: AppTheme.padding, bottom: AppTheme.padding * 2),
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
                    isDarkMode: isDarkMode,
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
    required bool isDarkMode,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final cardColor = isDarkMode ? const Color(0xFF2D3142) : Colors.white;

    return Card(
      elevation: isDarkMode ? 4.0 : 0.0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        side: isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: AppTheme.padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          boxShadow:
              isDarkMode
                  ? []
                  : ShadowUtils.getLightModeCardShadow(
                    opacity: 0.08,
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.padding),
          child: Row(
            children: [
              // Rank circle
              _buildRankCircle(context, rank, isDarkMode),
              const SizedBox(width: 16),

              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (date != null)
                      Text(
                        _formatDate(date),
                        style: textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),

              // Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF5C6BC0).withOpacity(0.2)
                          : const Color(0xFF4A6FFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      isDarkMode
                          ? Border.all(color: const Color(0xFF5C6BC0).withOpacity(0.5), width: 1)
                          : null,
                  boxShadow:
                      isDarkMode
                          ? null
                          : [
                            BoxShadow(
                              color: const Color(0xFF4A6FFF).withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                ),
                child: Text(
                  '$score pts',
                  style: textTheme.titleSmall?.copyWith(
                    color: isDarkMode ? const Color(0xFF8C9EFF) : const Color(0xFF4A6FFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankCircle(BuildContext context, int rank, bool isDarkMode) {
    final size = rank <= 3 ? 48.0 : 40.0;
    final color = _getRankColor(rank, isDarkMode);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: isDarkMode ? 1 : 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: rank <= 3 && !isDarkMode ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: rank <= 3 ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank, bool isDarkMode) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return isDarkMode
            ? const Color(0xFF5C6BC0) // A brighter indigo for dark mode
            : const Color(0xFF4A6FFF).withOpacity(0.7);
    }
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    required bool isDarkMode,
  }) {
    return FilterChip(
      selected: isSelected,
      selectedColor:
          isDarkMode
              ? const Color(0xFF5C6BC0) // Brighter indigo color
              : const Color(0xFF4A6FFF).withOpacity(0.15),
      backgroundColor: isDarkMode ? const Color(0xFF363A54) : Colors.grey.shade200,
      checkmarkColor: Colors.white,
      label: Text(
        label,
        style: TextStyle(
          color:
              isSelected
                  ? (isDarkMode ? Colors.white : const Color(0xFF4A6FFF))
                  : (isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7)),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: onSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side:
            isSelected
                ? BorderSide(
                  color: isDarkMode ? Colors.white.withOpacity(0.6) : const Color(0xFF4A6FFF),
                  width: 1.5,
                )
                : BorderSide.none,
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: isDarkMode ? 0 : 1,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildEmptyLeaderboard(BuildContext context, bool isDarkMode) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: isDarkMode ? const Color(0xFF1A1C2A) : Colors.grey.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                    blurRadius: 10,
                    spreadRadius: isDarkMode ? 1 : 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 60,
                color:
                    isDarkMode
                        ? const Color(0xFF5C6BC0).withOpacity(0.7)
                        : const Color(0xFF4A6FFF).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(AppTheme.padding),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                    blurRadius: 10,
                    spreadRadius: isDarkMode ? 1 : 0,
                  ),
                ],
                border: isDarkMode ? Border.all(color: Colors.grey.shade800, width: 1) : null,
              ),
              child: Column(
                children: [
                  Text(
                    'No leaderboard entries yet',
                    style: textTheme.headlineSmall?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Play some games to start seeing scores on the leaderboard!',
                    style: textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
