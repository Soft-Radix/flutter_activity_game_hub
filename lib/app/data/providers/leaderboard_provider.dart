import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:random_string/random_string.dart';

import '../models/leaderboard_entry_model.dart';

class LeaderboardProvider extends GetxService {
  static const String _boxName = 'leaderboard';
  late Box<LeaderboardEntry> _leaderboardBox;

  // Initialize the Hive box
  Future<LeaderboardProvider> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _leaderboardBox = await Hive.openBox<LeaderboardEntry>(_boxName);
    } else {
      _leaderboardBox = Hive.box<LeaderboardEntry>(_boxName);
    }

    return this;
  }

  // Get all entries
  List<LeaderboardEntry> getAllEntries() {
    return _leaderboardBox.values.toList();
  }

  // Get entries for a specific game
  List<LeaderboardEntry> getEntriesByGameId(String gameId) {
    return _leaderboardBox.values.where((entry) => entry.gameId == gameId).toList();
  }

  // Get entries for a specific player or team
  List<LeaderboardEntry> getEntriesByPlayerOrTeam(String playerOrTeamName) {
    return _leaderboardBox.values
        .where(
          (entry) =>
              entry.playerOrTeamName == playerOrTeamName ||
              (entry.playerNames != null && entry.playerNames!.contains(playerOrTeamName)),
        )
        .toList();
  }

  // Get entries from a specific time period
  List<LeaderboardEntry> getEntriesFromPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _leaderboardBox.values
        .where((entry) => entry.datePlayed.isAfter(startDate) && entry.datePlayed.isBefore(endDate))
        .toList();
  }

  // Add a new entry
  Future<void> addEntry(LeaderboardEntry entry) async {
    await _leaderboardBox.put(entry.id, entry);
  }

  // Get top entries (highest scores)
  List<LeaderboardEntry> getTopEntries({int limit = 10}) {
    final entries = getAllEntries();
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries.take(limit).toList();
  }

  // Get top entries for a specific game (highest scores)
  List<LeaderboardEntry> getTopEntriesForGame({required String gameId, int limit = 10}) {
    final entries = getEntriesByGameId(gameId);
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries.take(limit).toList();
  }

  // Create a new entry with a generated ID
  Future<void> createEntry({
    required String playerOrTeamName,
    required String gameId,
    required String gameName,
    required int score,
    List<String>? playerNames,
  }) async {
    final entry = LeaderboardEntry(
      id: randomAlphaNumeric(10),
      playerOrTeamName: playerOrTeamName,
      gameId: gameId,
      gameName: gameName,
      score: score,
      datePlayed: DateTime.now(),
      playerNames: playerNames,
    );

    await addEntry(entry);
  }

  // Delete an entry
  Future<void> deleteEntry(String id) async {
    await _leaderboardBox.delete(id);
  }

  // Clear all entries
  Future<void> clearAllEntries() async {
    await _leaderboardBox.clear();
  }
}
