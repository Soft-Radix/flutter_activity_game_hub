import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:random_string/random_string.dart';

import '../models/game_model.dart';

class GameProvider extends GetxService {
  static const String _boxName = 'games';
  late Box<Game> _gamesBox;

  // Initialize the Hive box
  Future<GameProvider> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _gamesBox = await Hive.openBox<Game>(_boxName);
    } else {
      _gamesBox = Hive.box<Game>(_boxName);
    }

    // If the box is empty, populate with sample games
    if (_gamesBox.isEmpty) {
      await _populateSampleGames();
    }

    return this;
  }

  // Get all games
  List<Game> getAllGames() {
    return _gamesBox.values.toList();
  }

  // Get a game by id
  Game? getGameById(String id) {
    try {
      return _gamesBox.values.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get games by category
  List<Game> getGamesByCategory(String category) {
    return _gamesBox.values.where((game) => game.category == category).toList();
  }

  // Get featured games
  List<Game> getFeaturedGames() {
    return _gamesBox.values.where((game) => game.isFeatured).toList();
  }

  // Add a new game
  Future<void> addGame(Game game) async {
    await _gamesBox.put(game.id, game);
  }

  // Update a game
  Future<void> updateGame(Game game) async {
    await _gamesBox.put(game.id, game);
  }

  // Delete a game
  Future<void> deleteGame(String id) async {
    await _gamesBox.delete(id);
  }

  // Get a random game
  Game getRandomGame() {
    final games = getAllGames();
    games.shuffle();
    return games.first;
  }

  // Private helper method to populate sample games
  Future<void> _populateSampleGames() async {
    final sampleGames = [
      Game(
        id: randomAlphaNumeric(10),
        name: 'Two Truths and a Lie',
        description:
            'Each person shares three statements about themselves - two true and one false. The group tries to guess which statement is the lie.',
        category: 'Icebreakers',
        imageUrl: 'assets/images/placeholder.svg',
        minPlayers: 3,
        maxPlayers: 20,
        estimatedTimeMinutes: 15,
        instructions: [
          'Each player thinks of two true statements and one false statement about themselves',
          'One by one, players share their three statements in random order',
          'The group discusses and votes on which statement they believe is the lie',
          'The player reveals which statement was the lie',
          'Continue until everyone has had a turn',
        ],
        isFeatured: true,
      ),
      Game(
        id: randomAlphaNumeric(10),
        name: 'Office Pictionary',
        description: 'Teams take turns drawing and guessing office-related terms to earn points.',
        category: 'Team-Building',
        imageUrl: 'assets/images/placeholder.svg',
        minPlayers: 4,
        maxPlayers: 20,
        estimatedTimeMinutes: 30,
        instructions: [
          'Divide into two or more teams',
          'One person from a team draws a word/phrase without speaking',
          'Their team tries to guess the word/phrase within the time limit',
          'If the team guesses correctly, they get a point',
          'Teams take turns drawing and guessing',
          'The team with the most points at the end wins',
        ],
        isFeatured: false,
      ),
      Game(
        id: randomAlphaNumeric(10),
        name: 'Word Association Chain',
        description:
            'A quick-thinking word game where players must respond with a related word based on the previous player\'s word.',
        category: 'Brain Games',
        imageUrl: 'assets/images/placeholder.svg',
        minPlayers: 3,
        maxPlayers: 15,
        estimatedTimeMinutes: 10,
        instructions: [
          'Players sit or stand in a circle',
          'The first player says a word',
          'The next player must say a word that is associated with the previous word',
          'Continue around the circle with each player building on the previous word',
          'If a player takes too long or repeats a word, they\'re out',
          'The last player remaining wins',
        ],
        isFeatured: false,
      ),
      Game(
        id: randomAlphaNumeric(10),
        name: 'Office Trivia',
        description:
            'Test your knowledge about your workplace and colleagues in this fun trivia game.',
        category: 'Quick Games',
        imageUrl: 'assets/images/placeholder.svg',
        minPlayers: 3,
        maxPlayers: 30,
        estimatedTimeMinutes: 20,
        instructions: [
          'Prepare trivia questions about your company, office, or colleagues',
          'Divide participants into teams',
          'Ask questions and give teams time to discuss and submit answers',
          'Award points for correct answers',
          'The team with the most points at the end wins',
        ],
        isFeatured: true,
      ),
    ];

    for (final game in sampleGames) {
      await _gamesBox.put(game.id, game);
    }
  }
}
