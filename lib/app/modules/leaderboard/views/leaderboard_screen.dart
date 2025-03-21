import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/leaderboard_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../data/models/game_model.dart';
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

                // Add detailed game history section
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 24),

                Row(
                  children: [
                    Icon(Icons.view_list, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Detailed Game History',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Show details button
                    GestureDetector(
                      onTap: () => _showDetailedGameHistory(context, controller, isDarkMode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'View All',
                              style: textTheme.bodySmall?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                          gameName: topGamers[index]['gameName'] as String?,
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
                    gameName: entry.gameName,
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
    String? gameName,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final leaderboardController = Get.find<LeaderboardController>();

    // Dynamic colors based on rank
    Color getRankColor() {
      if (rank == 1) return Colors.amber; // Gold
      if (rank == 2) return Colors.grey.shade300; // Silver
      if (rank == 3) return Colors.brown.shade300; // Bronze
      return isDarkMode ? Colors.white70 : Colors.black54;
    }

    // Get game details if possible
    Game? gameDetails;
    String? gameId;

    if (gameName != null) {
      // Try to get game details if we have the name
      final recentGames = leaderboardController.getRecentGamesPlayedByUser(name, limit: 5);
      for (final game in recentGames) {
        if (game.gameName == gameName) {
          gameDetails = leaderboardController.findGameById(game.gameId);
          gameId = game.gameId; // Save the game ID for tap handler
          break;
        }
      }
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
      child: InkWell(
        onTap:
            gameId != null
                ? () => _showGamePlayerDetailsDialog(gameId!, leaderboardController)
                : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game name and rank
              Row(
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

                  // Game info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                gameName ?? name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

                        // Difficulty and Rating
                        if (gameDetails != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildRatingBadge(context, gameDetails.rating, isDarkMode),
                              const SizedBox(width: 8),
                              _buildDifficultyBadge(
                                context,
                                gameDetails.difficultyLevel,
                                isDarkMode,
                              ),
                            ],
                          ),
                        ],

                        // Completion date
                        if (date != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Completed: ${_formatDateWithTime(date)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // "Tap to view players" hint
              if (gameId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        size: 14,
                        color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to view players',
                        style: textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Simplified dialog to show only player information for a specific game
  void _showGamePlayerDetailsDialog(String gameId, LeaderboardController controller) {
    // First check if the game exists and retrieve game information
    final game = controller.findGameById(gameId);
    if (game == null) {
      Get.dialog(
        AlertDialog(
          title: Text('Game Not Found'),
          content: Text('Could not find game with ID: $gameId'),
          actions: [TextButton(onPressed: () => Get.back(), child: Text('CLOSE'))],
        ),
      );
      return;
    }

    final allPlayersForGame = controller.getPlayersForGame(gameId);

    // Get entries for this game
    final gameEntries = controller.allEntries.where((entry) => entry.gameId == gameId).toList();

    if (gameEntries.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('No Game Data Found'),
          content: Text('No game history entries found for this game.'),
          actions: [TextButton(onPressed: () => Get.back(), child: Text('CLOSE'))],
        ),
      );
      return;
    }

    // Sort the entries by date (most recent first) and get the most recent one
    gameEntries.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
    final mostRecentEntry = gameEntries.first;

    final DateTime completionDate = mostRecentEntry.datePlayed;
    final String gameName = game.name; // Use the actual game name from the game object
    final int score = mostRecentEntry.score;

    if (allPlayersForGame.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('No Players Found'),
          content: Text('No player data found for this game.'),
          actions: [TextButton(onPressed: () => Get.back(), child: Text('CLOSE'))],
        ),
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.emoji_events, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gameName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Completed on ${DateFormat('MMM d, yyyy').format(completionDate)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Score: $score',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Players Section
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${allPlayersForGame.length}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Players', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),

              SizedBox(height: 12),

              // Player List
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      allPlayersForGame.map((player) {
                        final name = player['name'] as String;
                        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundColor: _getAvatarColor(name),
                                radius: 14,
                                child: Text(
                                  firstLetter,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                name,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              SizedBox(height: 20),

              // Close Button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'CLOSE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to generate avatar colors based on player name
  Color _getAvatarColor(String name) {
    final List<Color> colors = [
      Colors.blue.shade700,
      Colors.red.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
      Colors.teal.shade700,
      Colors.pink.shade700,
      Colors.indigo.shade700,
    ];

    // Generate a consistent color based on name's hash code
    final int colorIndex = name.hashCode.abs() % colors.length;
    return colors[colorIndex];
  }

  // Helper to create a rating badge
  Widget _buildRatingBadge(
    BuildContext context,
    double rating,
    bool isDarkMode, {
    bool large = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final iconSize = large ? 18.0 : 14.0;
    final textStyle =
        large
            ? textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade800,
            )
            : textTheme.bodySmall?.copyWith(
              color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade800,
            );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 10.0 : 6.0, vertical: large ? 6.0 : 3.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.amber.withOpacity(0.15) : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(large ? 10.0 : 8.0),
        border: Border.all(
          color: isDarkMode ? Colors.amber.withOpacity(0.3) : Colors.amber.shade200,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: iconSize,
            color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700,
          ),
          SizedBox(width: large ? 6.0 : 3.0),
          Text('$rating', style: textStyle),
        ],
      ),
    );
  }

  // Helper to create a difficulty badge
  Widget _buildDifficultyBadge(
    BuildContext context,
    String difficulty,
    bool isDarkMode, {
    bool large = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final iconSize = large ? 18.0 : 14.0;

    // Color based on difficulty
    MaterialColor getColor() {
      if (difficulty.toLowerCase().contains('easy')) return Colors.green;
      if (difficulty.toLowerCase().contains('medium')) return Colors.orange;
      if (difficulty.toLowerCase().contains('hard')) return Colors.red;
      return Colors.blue;
    }

    final color = getColor();
    final textStyle =
        large
            ? textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? color.shade300 : color.shade700,
            )
            : textTheme.bodySmall?.copyWith(color: isDarkMode ? color.shade300 : color.shade700);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 10.0 : 6.0, vertical: large ? 6.0 : 3.0),
      decoration: BoxDecoration(
        color: isDarkMode ? color.withOpacity(0.15) : color.shade50,
        borderRadius: BorderRadius.circular(large ? 10.0 : 8.0),
        border: Border.all(color: isDarkMode ? color.withOpacity(0.3) : color.shade200, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: iconSize, color: isDarkMode ? color.shade300 : color.shade700),
          SizedBox(width: large ? 6.0 : 3.0),
          Text(difficulty, style: textStyle),
        ],
      ),
    );
  }

  // Format date with time
  String _formatDateWithTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    String prefix;
    if (dateToCheck == today) {
      prefix = 'Today';
    } else if (dateToCheck == yesterday) {
      prefix = 'Yesterday';
    } else {
      prefix = '${date.day}/${date.month}/${date.year}';
    }

    // Add time
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$prefix at $hour:$minute';
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

  // New method to show detailed game history dialog
  void _showDetailedGameHistory(
    BuildContext context,
    LeaderboardController controller,
    bool isDarkMode,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final currentUserName = 'You'; // This would come from user preferences in a real app
    final userEntries = controller.getAllUserEntries(currentUserName);

    Get.dialog(
      Dialog(
        backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header
              Row(
                children: [
                  Icon(
                    Icons.sports_esports,
                    color: isDarkMode ? Colors.blue : Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your Game History',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : Colors.black54),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Game history list
              userEntries.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 48,
                            color: isDarkMode ? Colors.white54 : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No games played yet',
                            style: textTheme.titleMedium?.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Container(
                    constraints: BoxConstraints(maxHeight: Get.height * 0.6),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: userEntries.length,
                      itemBuilder: (context, index) {
                        final entry = userEntries[index];
                        final game = controller.findGameById(entry.gameId);

                        // Get player names to display
                        final String playerInfo = _getPlayerDisplayText(entry);

                        return InkWell(
                          onTap:
                              () => _showGameDetailsDialog(
                                context,
                                entry,
                                game,
                                controller,
                                isDarkMode,
                              ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.gameName,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isDarkMode
                                                ? Colors.blue.withOpacity(0.2)
                                                : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Score: ${entry.score}',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDarkMode
                                                  ? Colors.blue.shade200
                                                  : Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Players: $playerInfo',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: isDarkMode ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Played: ${_formatDate(entry.datePlayed)}',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                if (game != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rate,
                                        size: 16,
                                        color: isDarkMode ? Colors.amber : Colors.amber.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rating: ${game.rating}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: isDarkMode ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.speed,
                                        size: 16,
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Difficulty: ${game.difficultyLevel}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: isDarkMode ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed:
                                        () => _showGameDetailsDialog(
                                          context,
                                          entry,
                                          game,
                                          controller,
                                          isDarkMode,
                                        ),
                                    icon: Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color:
                                          isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                                    ),
                                    label: Text(
                                      'View Details',
                                      style: textTheme.bodySmall?.copyWith(
                                        color:
                                            isDarkMode
                                                ? Colors.blue.shade300
                                                : Colors.blue.shade700,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
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
      ),
    );
  }

  // Helper method to get player display text from entry
  String _getPlayerDisplayText(LeaderboardEntry entry) {
    if (entry.playerNames != null && entry.playerNames!.isNotEmpty) {
      // If there are more than 2 players, show the first one and a count
      if (entry.playerNames!.length > 2) {
        return '${entry.playerNames!.first} + ${entry.playerNames!.length - 1} more';
      } else {
        return entry.playerNames!.join(", ");
      }
    } else {
      return entry.playerOrTeamName;
    }
  }

  // New method to show detailed game information
  void _showGameDetailsDialog(
    BuildContext context,
    LeaderboardEntry entry,
    Game? game,
    LeaderboardController controller,
    bool isDarkMode,
  ) {
    final textTheme = Theme.of(context).textTheme;

    // Get all players who played this game
    final allPlayersForGame = controller.getPlayersForGame(entry.gameId);

    // If we can't find the game, show a simple error dialog
    if (game == null && allPlayersForGame.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('Game Details Not Available'),
          content: Text('Could not find detailed information for this game.'),
          actions: [TextButton(onPressed: () => Get.back(), child: Text('CLOSE'))],
        ),
      );
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.videogame_asset,
                        size: 32,
                        color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.gameName,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (game != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Category: ${game.category}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : Colors.black54),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Game details
              if (game != null) ...[
                _buildDetailSection(context, 'Game Details', [
                  _buildDetailRow(
                    context,
                    'Difficulty',
                    game.difficultyLevel,
                    Icons.speed,
                    isDarkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Rating',
                    '${game.rating}',
                    Icons.star_rate,
                    isDarkMode,
                    iconColor: Colors.amber,
                  ),
                  _buildDetailRow(
                    context,
                    'Players Needed',
                    '${game.minPlayers}-${game.maxPlayers}',
                    Icons.group,
                    isDarkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Estimated Time',
                    '${game.estimatedTimeMinutes} minutes',
                    Icons.timer,
                    isDarkMode,
                  ),
                  _buildDetailRow(context, 'Game Type', game.gameType, Icons.category, isDarkMode),
                  _buildDetailRow(
                    context,
                    'Team Based',
                    game.teamBased ? 'Yes' : 'No',
                    Icons.people_alt,
                    isDarkMode,
                  ),
                ], isDarkMode),

                const SizedBox(height: 16),

                // Game description
                _buildDetailSection(context, 'Game Description', [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      game.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ], isDarkMode),
              ],

              const SizedBox(height: 16),

              // Players who played this game
              if (allPlayersForGame.isNotEmpty)
                _buildDetailSection(context, 'All Players', [
                  for (final player in allPlayersForGame)
                    _buildPlayerRow(context, player, isDarkMode),
                ], isDarkMode)
              else
                _buildDetailSection(context, 'Players', [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No player information available',
                      style: textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ], isDarkMode),

              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  if (game != null)
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.back(); // Close both dialogs if nested
                        controller.navigateToGameDetails(entry.gameId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.blue.shade700 : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Play Again'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build detail sections
  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> children,
    bool isDarkMode,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDarkMode, {
    Color? iconColor,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? (isDarkMode ? Colors.white70 : Colors.black54)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build player rows
  Widget _buildPlayerRow(BuildContext context, Map<String, dynamic> player, bool isDarkMode) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.shade100,
            ),
            child: Center(
              child: Text(
                (player['name'] as String).substring(0, 1).toUpperCase(),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'] as String,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Played on ${_formatDate(player['datePlayed'] as DateTime)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Score: ${player['score']}',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
