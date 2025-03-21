import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/game_model.dart';
import '../services/gemini_api_service.dart';

class GeminiGameProvider extends GetxService {
  static const String _boxName = 'games';
  late Box<Game> _gamesBox;
  final GeminiApiService _geminiApiService = GeminiApiService();

  // Local cache to avoid multiple API calls for the same search
  final Map<String, List<Game>> _cachedGames = {};

  // Initialize the Hive box
  Future<GeminiGameProvider> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _gamesBox = await Hive.openBox<Game>(_boxName);
    } else {
      _gamesBox = Hive.box<Game>(_boxName);
    }
    return this;
  }

  // Get all games from Gemini
  Future<List<Game>> getAllGames() async {
    // Check cache first
    if (_cachedGames.containsKey('all')) {
      return _cachedGames['all']!;
    }

    // Get games from API
    final games = await _geminiApiService.getGames();

    // Save to cache
    _cachedGames['all'] = games;

    // Save to local storage for offline access
    for (final game in games) {
      await _gamesBox.put(game.id, game);
    }

    return games;
  }

  // Get a game by id (first try API, then local cache)
  Future<Game?> getGameById(String id) async {
    try {
      // Try to get from API first
      final game = await _geminiApiService.getGameDetails(id);

      if (game != null) {
        // Save to local storage
        await _gamesBox.put(game.id, game);
        return game;
      }

      // If API fails, try from local storage
      return _gamesBox.values.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get games by category
  Future<List<Game>> getGamesByCategory(String category) async {
    // Check cache first
    if (_cachedGames.containsKey('category_$category')) {
      return _cachedGames['category_$category']!;
    }

    // Get from API
    final games = await _geminiApiService.getGames(category: category);

    // Save to cache
    _cachedGames['category_$category'] = games;

    // Save to local storage
    for (final game in games) {
      await _gamesBox.put(game.id, game);
    }

    return games;
  }

  // Get games by player count
  Future<List<Game>> getGamesByPlayerCount(int playerCount) async {
    // Check cache first
    if (_cachedGames.containsKey('players_$playerCount')) {
      return _cachedGames['players_$playerCount']!;
    }

    // Get from API
    final games = await _geminiApiService.getGames(
      minPlayers: playerCount,
      maxPlayers: playerCount,
    );

    // Save to cache
    _cachedGames['players_$playerCount'] = games;

    // Save to local storage
    for (final game in games) {
      await _gamesBox.put(game.id, game);
    }

    return games;
  }

  // Get games by maximum time
  Future<List<Game>> getGamesByMaxTime(int maxTimeMinutes) async {
    // Check cache first
    if (_cachedGames.containsKey('time_$maxTimeMinutes')) {
      return _cachedGames['time_$maxTimeMinutes']!;
    }

    // Get from API
    final games = await _geminiApiService.getGames(maxTimeMinutes: maxTimeMinutes);

    // Save to cache
    _cachedGames['time_$maxTimeMinutes'] = games;

    // Save to local storage
    for (final game in games) {
      await _gamesBox.put(game.id, game);
    }

    return games;
  }

  // Get games with combined filters
  Future<List<Game>> getGamesWithFilters({
    String? category,
    int? minPlayers,
    int? maxPlayers,
    int? maxTimeMinutes,
  }) async {
    // Build cache key
    String cacheKey = 'filter';
    if (category != null) cacheKey += '_cat_$category';
    if (minPlayers != null) cacheKey += '_min_$minPlayers';
    if (maxPlayers != null) cacheKey += '_max_$maxPlayers';
    if (maxTimeMinutes != null) cacheKey += '_time_$maxTimeMinutes';

    // Check cache first
    if (_cachedGames.containsKey(cacheKey)) {
      return _cachedGames[cacheKey]!;
    }

    // Get from API
    final games = await _geminiApiService.getGames(
      category: category,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      maxTimeMinutes: maxTimeMinutes,
    );

    // Save to cache
    _cachedGames[cacheKey] = games;

    // Save to local storage
    for (final game in games) {
      await _gamesBox.put(game.id, game);
    }

    return games;
  }

  // Get featured games
  Future<List<Game>> getFeaturedGames() async {
    // First try to get all games
    final allGames = await getAllGames();

    // Filter for featured games
    final featuredGames = allGames.where((game) => game.isFeatured).toList();

    // If we have featured games, return them
    if (featuredGames.isNotEmpty) {
      return featuredGames;
    }

    // If no featured games from API, use local storage
    return _gamesBox.values.where((game) => game.isFeatured).toList();
  }

  // Clear cache
  void clearCache() {
    _cachedGames.clear();
  }
}
