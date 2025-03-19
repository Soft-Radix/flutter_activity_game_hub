import 'package:hive/hive.dart';

part 'leaderboard_entry_model.g.dart';

@HiveType(typeId: 1)
class LeaderboardEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String playerOrTeamName;

  @HiveField(2)
  final String gameId;

  @HiveField(3)
  final String gameName;

  @HiveField(4)
  final int score;

  @HiveField(5)
  final DateTime datePlayed;

  LeaderboardEntry({
    required this.id,
    required this.playerOrTeamName,
    required this.gameId,
    required this.gameName,
    required this.score,
    required this.datePlayed,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      playerOrTeamName: json['playerOrTeamName'] as String,
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      score: json['score'] as int,
      datePlayed: DateTime.parse(json['datePlayed'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerOrTeamName': playerOrTeamName,
      'gameId': gameId,
      'gameName': gameName,
      'score': score,
      'datePlayed': datePlayed.toIso8601String(),
    };
  }
}
