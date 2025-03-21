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
                isGameSpecific ? 'Game History' : 'Game History',
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
                'Game History',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'View your gaming activity and completed games',
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
    // Get the top players with most games played
    final topGamers = controller.getPlayersWithMostGames();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserName = 'You'; // This would come from user preferences in a real app
    final userRank = controller.getUserGlobalRankByGamesPlayed(currentUserName);
    final recentGames = controller.getRecentGamesPlayedByUser(currentUserName);

    return Column(
      children: [
        // Add personal stats section at the top
        if (userRank > 0)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDarkMode ? const Color(0xFF4A6FFF) : Colors.blue.shade500,
                  isDarkMode ? const Color(0xFF3051D3) : Colors.blue.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sports_esports, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Rank (By Games Played)',
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#$userRank',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Games Played',
                          style: textTheme.titleSmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${topGamers.firstWhere((p) => p['name'] == currentUserName, orElse: () => {'name': '', 'gamesCount': 0})['gamesCount']}',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Add recent games
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  children: [
                    Icon(Icons.history, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Recently Played Games',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recent games list
                SizedBox(
                  height: 70,
                  child:
                      recentGames.isEmpty
                          ? Center(
                            child: Text(
                              'No games played yet',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentGames.length,
                            itemBuilder: (context, index) {
                              final entry = recentGames[index];
                              return GestureDetector(
                                onTap: () => controller.navigateToGameDetails(entry.gameId),
                                child: Container(
                                  width: 130,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        entry.gameName,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(entry.datePlayed),
                                        style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),

        // Improved section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.star_border_rounded,
                size: 22,
                color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Top Gaming Enthusiasts',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Player entries
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: isDarkMode ? const Color(0xFF1A1C2A) : Colors.grey.shade50,
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: topGamers.length,
                itemBuilder: (context, index) {
                  final bool isUser = topGamers[index]['name'] == currentUserName;

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildPlayerGameCard(
                          context,
                          name: topGamers[index]['name'] as String,
                          gamesCount: topGamers[index]['gamesCount'] as int,
                          rank: index + 1,
                          isDarkMode: isDarkMode,
                          isCurrentUser: isUser,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
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
                  child: _buildPlayerGameCard(
                    context,
                    name: entry.playerOrTeamName,
                    gamesCount: 1, // Single game entry
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

  Widget _buildPlayerGameCard(
    BuildContext context, {
    required String name,
    required int gamesCount,
    required int rank,
    DateTime? date,
    required bool isDarkMode,
    bool isCurrentUser = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    // Dynamic colors based on rank
    Color getRankColor() {
      if (rank == 1) return Colors.amber; // Gold
      if (rank == 2) return Colors.grey.shade300; // Silver
      if (rank == 3) return Colors.brown.shade300; // Bronze
      return isDarkMode ? Colors.white70 : Colors.black54;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? isDarkMode
                    ? const Color(0xFF3051D3).withOpacity(0.15)
                    : Colors.blue.shade50
                : isDarkMode
                ? const Color(0xFF252842)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isCurrentUser
                ? Border.all(color: isDarkMode ? const Color(0xFF4A6FFF) : Colors.blue, width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Rank container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    rank <= 3
                        ? getRankColor().withOpacity(0.15)
                        : isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: rank <= 3 ? Border.all(color: getRankColor(), width: 1.5) : null,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        rank <= 3
                            ? getRankColor()
                            : isDarkMode
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? const Color(0xFF4A6FFF).withOpacity(0.2)
                                    : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'You',
                            style: textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.sports_esports,
                        size: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$gamesCount ${gamesCount == 1 ? 'Game' : 'Games'} Played',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trophy icon for top 3
            if (rank <= 3) Icon(Icons.emoji_events, color: getRankColor(), size: 24),
          ],
        ),
      ),
    );
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
    final leaderboardController = Get.find<LeaderboardController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF252842) : const Color(0xFFEFF1FD),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_esports,
                size: 60,
                color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No game history yet',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Play some games to start building your gaming history!',
              style: textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
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
