import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/category_model.dart';
import '../data/models/game_model.dart';
import '../data/providers/gemini_game_provider.dart';

class GeminiAppController extends GetxController {
  final GeminiGameProvider _gameProvider = Get.find<GeminiGameProvider>();

  // Observable variables
  final RxList<Game> games = <Game>[].obs;
  final RxList<Game> featuredGames = <Game>[].obs;
  final RxList<GameCategory> categories = <GameCategory>[].obs;
  final Rx<GameCategory?> selectedCategory = Rx<GameCategory?>(null);
  final RxBool isLoading = false.obs;

  // Advanced filtering options
  final RxInt selectedPlayerCount = 0.obs;
  final RxInt selectedMaxTime = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadGames();
    loadCategories();
  }

  // Load all games using Gemini API
  Future<void> loadGames() async {
    isLoading.value = true;
    try {
      games.value = await _gameProvider.getAllGames();
      featuredGames.value = await _gameProvider.getFeaturedGames();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load games: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      // Simple categories based on games (can be enhanced later)
      // This will be replaced with a proper API call in the future
      final Set<String> categoryNames = <String>{};
      for (var game in games) {
        if (game.category.isNotEmpty) {
          categoryNames.add(game.category);
        }
      }

      // Convert to GameCategory objects
      final categoryList =
          categoryNames.map((name) {
            return GameCategory(
              id: name.toLowerCase().replaceAll(' ', '-'),
              name: name,
              description: '$name games',
              color: _getCategoryColor(name),
              iconPath: _getCategoryIconPath(name),
            );
          }).toList();

      categories.value = categoryList;
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // Get games by category using Gemini API
  Future<List<Game>> getGamesByCategory(String category, {int? pageSize, int? page}) async {
    isLoading.value = true;
    try {
      final fetchedGames = await _gameProvider.getGamesByCategory(
        category,
        pageSize: pageSize,
        page: page,
      );

      // Only update the main games list if this is the first page or not paginated
      if (page == null || page == 1) {
        games.value = fetchedGames;
      }

      return fetchedGames;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load games by category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Get games with filters
  Future<void> getGamesWithFilters() async {
    isLoading.value = true;
    try {
      String? category = selectedCategory.value?.name;
      int? minPlayers = selectedPlayerCount.value > 0 ? selectedPlayerCount.value : null;
      int? maxTime = selectedMaxTime.value > 0 ? selectedMaxTime.value : null;

      games.value = await _gameProvider.getGamesWithFilters(
        category: category,
        minPlayers: minPlayers,
        maxPlayers: minPlayers, // Use same value for min and max for exact match
        maxTimeMinutes: maxTime,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load games: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset all filters
  void resetFilters() {
    selectedCategory.value = null;
    selectedPlayerCount.value = 0;
    selectedMaxTime.value = 0;
    loadGames();
  }

  // Get game details
  Future<Game?> getGameDetails(String id) async {
    isLoading.value = true;
    try {
      return await _gameProvider.getGameById(id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load game details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Set player count filter
  void setPlayerCount(int count) {
    selectedPlayerCount.value = count;
    getGamesWithFilters();
  }

  // Set max time filter
  void setMaxTime(int minutes) {
    selectedMaxTime.value = minutes;
    getGamesWithFilters();
  }

  // Set category filter
  void setCategory(GameCategory category) {
    selectedCategory.value = category;
    getGamesWithFilters();
  }

  // Get filtered or all games depending on whether filters are applied
  List<Game> getFilteredOrAllGames() {
    if (selectedCategory.value != null ||
        selectedPlayerCount.value > 0 ||
        selectedMaxTime.value > 0) {
      return games;
    } else {
      return games;
    }
  }

  // Clear the game provider cache
  void clearCache() {
    _gameProvider.clearCache();
    loadGames();
  }

  // Get search suggestions using Gemini API
  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // Use _gameProvider to get suggestions
      return await _gameProvider.getSearchSuggestions(query);
    } catch (e) {
      print('Error getting suggestions: $e');
      return [];
    }
  }

  // Helper to generate colors for categories
  Color _getCategoryColor(String categoryName) {
    // Simple mapping based on category name
    final lowerCaseName = categoryName.toLowerCase();

    if (lowerCaseName.contains('ice') || lowerCaseName.contains('break')) {
      return Colors.blue;
    } else if (lowerCaseName.contains('team') || lowerCaseName.contains('building')) {
      return Colors.green;
    } else if (lowerCaseName.contains('brain') || lowerCaseName.contains('puzzle')) {
      return Colors.purple;
    } else if (lowerCaseName.contains('quick') || lowerCaseName.contains('fast')) {
      return Colors.orange;
    } else if (lowerCaseName.contains('outdoor')) {
      return Colors.lightGreen;
    } else if (lowerCaseName.contains('party')) {
      return Colors.pink;
    } else {
      // Default color
      return Colors.teal;
    }
  }

  // Get category icon path based on name
  String _getCategoryIconPath(String categoryName) {
    // Default icon paths based on category
    final lowerCaseName = categoryName.toLowerCase();

    if (lowerCaseName.contains('ice') || lowerCaseName.contains('break')) {
      return 'assets/icons/ice.svg';
    } else if (lowerCaseName.contains('team') || lowerCaseName.contains('building')) {
      return 'assets/icons/team.svg';
    } else if (lowerCaseName.contains('brain') || lowerCaseName.contains('puzzle')) {
      return 'assets/icons/brain.svg';
    } else if (lowerCaseName.contains('quick') || lowerCaseName.contains('fast')) {
      return 'assets/icons/clock.svg';
    } else {
      return 'assets/icons/game.svg';
    }
  }
}
