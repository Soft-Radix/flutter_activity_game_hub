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
    };
  }
}
