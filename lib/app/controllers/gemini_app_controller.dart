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
  void loadCategories() {
    // These are hardcoded categories for now
    // You could fetch them from the API in the future
    categories.value = [
      GameCategory(
        id: '1',
        name: 'Icebreakers',
        description: 'Games to help people get to know each other',
        iconPath: 'assets/icons/ice.svg',
        color: Colors.blue,
      ),
      GameCategory(
        id: '2',
        name: 'Team-Building',
        description: 'Games that help build team cohesion',
        iconPath: 'assets/icons/team.svg',
        color: Colors.green,
      ),
      GameCategory(
        id: '3',
        name: 'Brain Games',
        description: 'Games that challenge the mind',
        iconPath: 'assets/icons/brain.svg',
        color: Colors.purple,
      ),
      GameCategory(
        id: '4',
        name: 'Quick Games',
        description: 'Games that can be played quickly',
        iconPath: 'assets/icons/clock.svg',
        color: Colors.orange,
      ),
    ];
  }

  // Get games by category
  Future<void> getGamesByCategory(String category) async {
    isLoading.value = true;
    try {
      games.value = await _gameProvider.getGamesByCategory(category);
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
}
