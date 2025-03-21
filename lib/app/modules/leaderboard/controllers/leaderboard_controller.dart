import 'package:activity_game_hub_flutter/app/data/models/leaderboard_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/leaderboard_provider.dart'; 


class LeaderboardController extends GetxController {
  final LeaderboardProvider _leaderboardProvider = Get.find<LeaderboardProvider>();

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

  // Load leaderboard entries
  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    try {
      allEntries.value = _leaderboardProvider.getAllEntries();
      applyFilter(currentFilter.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load leaderboard: ${e.toString()}',
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

  // Get top players/teams (unique names, highest score)
  List<Map<String, dynamic>> getTopPlayersOrTeams({int limit = 10}) {
    final Map<String, int> playerScores = {};

    // Calculate the highest score for each player/team
    for (final entry in filteredEntries) {
      final currentHighScore = playerScores[entry.playerOrTeamName] ?? 0;
      if (entry.score > currentHighScore) {
        playerScores[entry.playerOrTeamName] = entry.score;
      }
    }

    // Convert to list and sort
    final topPlayers = playerScores.entries.map((e) => {'name': e.key, 'score': e.value}).toList();

    topPlayers.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return topPlayers.take(limit).toList();
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
        'Score added to leaderboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add score: ${e.toString()}',
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
}
