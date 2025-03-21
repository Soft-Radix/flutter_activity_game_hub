import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/game_model.dart';
import '../data/models/leaderboard_entry_model.dart';
import '../data/providers/game_provider.dart';
import '../data/providers/leaderboard_provider.dart';

class LeaderboardController extends GetxController {
  final LeaderboardProvider _leaderboardProvider = Get.find<LeaderboardProvider>();
  final GameProvider _gameProvider = Get.find<GameProvider>();

  // Observable variables
  final RxList<LeaderboardEntry> allEntries = <LeaderboardEntry>[].obs;
  final RxList<LeaderboardEntry> filteredEntries = <LeaderboardEntry>[].obs;
  final RxString currentFilter = 'all'.obs; // all, week, month
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
  }

  // Find a game by ID
  Game? findGameById(String gameId) {
    try {
      final result = _gameProvider.getGameById(gameId);
      return result; // This will return null if not found
    } catch (e) {
      debugPrint('Error finding game by ID: $e');
      return null;
    }
  }

  // Navigate to game details
  void navigateToGameDetails(String gameId) {
    try {
      final game = findGameById(gameId);
      if (game != null) {
        Get.toNamed('/game-details', arguments: game);
      } else {
        Get.snackbar(
          'Game Not Found',
          'The selected game could not be found.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error navigating to game details: $e');
      Get.snackbar(
        'Error',
        'Could not navigate to game details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load leaderboard entries
  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    try {
      allEntries.value = _leaderboardProvider.getAllEntries();
      applyFilter(currentFilter.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load game history: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apply time filter
  void applyFilter(String filter) {
    currentFilter.value = filter;

    switch (filter) {
      case 'week':
        final DateTime now = DateTime.now();
        final DateTime weekAgo = now.subtract(const Duration(days: 7));
        filteredEntries.value = _leaderboardProvider.getEntriesFromPeriod(
          startDate: weekAgo,
          endDate: now,
        );
        break;

      case 'month':
        final DateTime now = DateTime.now();
        final DateTime monthAgo = now.subtract(const Duration(days: 30));
        filteredEntries.value = _leaderboardProvider.getEntriesFromPeriod(
          startDate: monthAgo,
          endDate: now,
        );
        break;

      case 'all':
      default:
        filteredEntries.value = allEntries;
        break;
    }

    // Sort entries by score (highest first)
    filteredEntries.sort((a, b) => b.score.compareTo(a.score));
  }

  // Get players with most games played (unique games count)
  List<Map<String, Object>> getPlayersWithMostGames({int limit = 10}) {
    final Map<String, Set<String>> playerGames = {};

    // Track unique games played by each player
    for (final entry in filteredEntries) {
      if (!playerGames.containsKey(entry.playerOrTeamName)) {
        playerGames[entry.playerOrTeamName] = <String>{};
      }

      // Add this game to the player's set of games
      playerGames[entry.playerOrTeamName]!.add(entry.gameId);
    }

    // Convert to list and sort by number of unique games played
    final List<Map<String, Object>> topGamers =
        playerGames.entries
            .map(
              (e) => {
                'name': e.key as Object,
                'gamesCount': e.value.length as Object,
                'gameIds': e.value.toList() as Object,
              },
            )
            .toList();

    topGamers.sort((a, b) => ((b['gamesCount'] as int).compareTo(a['gamesCount'] as int)));

    return topGamers.take(limit).toList();
  }

  // Get user's global rank by games played
  int getUserGlobalRankByGamesPlayed(String userName) {
    final topPlayers = getPlayersWithMostGames(limit: 100);
    for (int i = 0; i < topPlayers.length; i++) {
      if (topPlayers[i]['name'] == userName) {
        return i + 1;
      }
    }
    return 0; // Not ranked
  }

  // Get recent games played by a player
  List<LeaderboardEntry> getRecentGamesPlayedByUser(String userName, {int limit = 5}) {
    final userEntries = _leaderboardProvider.getEntriesByPlayerOrTeam(userName);

    // Sort by most recent date first
    userEntries.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));

    // Find unique games (most recent entry of each game)
    final Map<String, LeaderboardEntry> uniqueGames = {};
    for (final entry in userEntries) {
      if (!uniqueGames.containsKey(entry.gameId)) {
        uniqueGames[entry.gameId] = entry;
      }
    }

    // Return most recent entries
    return uniqueGames.values.toList().take(limit).toList();
  }

  // Add a new entry
  Future<void> addEntry({
    required String playerOrTeamName,
    required String gameId,
    required String gameName,
    required int score,
  }) async {
    try {
      await _leaderboardProvider.createEntry(
        playerOrTeamName: playerOrTeamName,
        gameId: gameId,
        gameName: gameName,
        score: score,
      );

      // Refresh leaderboard
      await loadLeaderboard();

      Get.snackbar(
        'Success',
        'Game added to your history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add game to history: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get top entries for a specific game
  List<LeaderboardEntry> getTopEntriesForGame(String gameId, {int limit = 10}) {
    return _leaderboardProvider.getTopEntriesForGame(gameId: gameId, limit: limit);
  }

  // Get user's personal best scores across games
  List<LeaderboardEntry> getUserPersonalBests(String userName) {
    final userEntries = _leaderboardProvider.getEntriesByPlayerOrTeam(userName);

    // Group by game and find best score for each
    final Map<String, LeaderboardEntry> bestScoresByGame = {};

    for (final entry in userEntries) {
      final existingBest = bestScoresByGame[entry.gameId];
      if (existingBest == null || entry.score > existingBest.score) {
        bestScoresByGame[entry.gameId] = entry;
      }
    }

    // Convert to list and sort by score (highest first)
    final personalBests = bestScoresByGame.values.toList();
    personalBests.sort((a, b) => b.score.compareTo(a.score));

    return personalBests;
  }
}
