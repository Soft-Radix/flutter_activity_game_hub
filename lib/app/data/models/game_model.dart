import 'package:hive/hive.dart';

part 'game_model.g.dart';

@HiveType(typeId: 0)
class Game {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final int minPlayers;

  @HiveField(6)
  final int maxPlayers;

  @HiveField(7)
  final int estimatedTimeMinutes;

  @HiveField(8)
  final List<String> instructions;

  @HiveField(9)
  final bool isFeatured;

  @HiveField(10)
  final String difficultyLevel; // Easy, Medium, Hard

  @HiveField(11)
  final List<String> materialsRequired; // Items needed for the game

  @HiveField(12)
  final String gameType; // Indoor, Outdoor, Desk-based

  @HiveField(13)
  final double rating; // Average rating of the game

  @HiveField(14)
  final bool isTimeBound; // Whether the game has a time limit

  @HiveField(15)
  final bool teamBased; // Whether it's a team-based game

  @HiveField(16)
  final List<String> rules; // List of rules for the game

  @HiveField(17)
  final String howToPlay; // Detailed explanation of how to play

  @HiveField(18)
  final String winnerGamePlayerOrTeam; // Winner of the game

  @HiveField(19)
  final List<String> outOfPlayRules; // List of rules for the game

  Game({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.minPlayers,
    required this.maxPlayers,
    required this.estimatedTimeMinutes,
    required this.instructions,
    this.isFeatured = false,
    required this.difficultyLevel,
    required this.materialsRequired,
    required this.gameType,
    required this.rating,
    required this.isTimeBound,
    required this.teamBased,
    required this.rules,
    required this.howToPlay,
    this.winnerGamePlayerOrTeam = '', // Default empty value
    this.outOfPlayRules = const [], // Default empty list
  });

  // Factory constructor to create a Game from a Map
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      minPlayers: json['minPlayers'] as int,
      maxPlayers: json['maxPlayers'] as int,
      estimatedTimeMinutes: json['estimatedTimeMinutes'] as int,
      instructions: List<String>.from(json['instructions']),
      isFeatured: json['isFeatured'] as bool? ?? false,
      difficultyLevel: json['difficultyLevel'] as String,
      materialsRequired: List<String>.from(json['materialsRequired']),
      gameType: json['gameType'] as String,
      rating: (json['rating'] as num).toDouble(),
      isTimeBound: json['isTimeBound'] as bool,
      teamBased: json['teamBased'] as bool,
      rules: List<String>.from(json['rules']),
      howToPlay: json['howToPlay'] as String,
      winnerGamePlayerOrTeam: json['winnerGamePlayerOrTeam'] as String? ?? '',
      outOfPlayRules:
          json['outOfPlayRules'] != null ? List<String>.from(json['outOfPlayRules']) : [],
    );
  }

  // Convert a Game to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'instructions': instructions,
      'isFeatured': isFeatured,
      'difficultyLevel': difficultyLevel,
      'materialsRequired': materialsRequired,
      'gameType': gameType,
      'rating': rating,
      'isTimeBound': isTimeBound,
      'teamBased': teamBased,
      'rules': rules,
      'howToPlay': howToPlay,
      'winnerGamePlayerOrTeam': winnerGamePlayerOrTeam,
      'outOfPlayRules': outOfPlayRules,
    };
  }
}
