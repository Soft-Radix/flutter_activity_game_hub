import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/category_model.dart';
import '../data/models/game_model.dart';
import '../data/providers/game_provider.dart';
import '../services/chatgpt_service.dart';

class AppController extends GetxController {
  final GameProvider _gameProvider = Get.find<GameProvider>();
  final ChatGptService _chatGptService = Get.find<ChatGptService>();

  // Observable variables
  final RxList<Game> games = <Game>[].obs;
  final RxList<Game> featuredGames = <Game>[].obs;
  final RxList<GameCategory> categories = <GameCategory>[].obs;
  final RxString gameSuggestion = ''.obs;
  final RxString gameOfTheDay = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGames();
    loadCategories();
    getGameSuggestion();
    getGameOfTheDay();
  }

  // Load all games
  Future<void> loadGames() async {
    isLoading.value = true;
    try {
      games.value = _gameProvider.getAllGames();
      featuredGames.value = _gameProvider.getFeaturedGames();
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
    // Define the categories
    categories.value = [
      GameCategory(
        id: 'icebreakers',
        name: 'Icebreakers',
        description: 'Quick games to help team members get to know each other',
        iconPath: 'assets/icons/ice.svg',
        color: Colors.blue,
      ),
      GameCategory(
        id: 'team-building',
        name: 'Team-Building',
        description: 'Activities that promote teamwork and collaboration',
        iconPath: 'assets/icons/team.svg',
        color: Colors.green,
      ),
      GameCategory(
        id: 'brain-games',
        name: 'Brain Games',
        description: 'Puzzles and games that challenge your mind',
        iconPath: 'assets/icons/brain.svg',
        color: Colors.purple,
      ),
      GameCategory(
        id: 'quick-games',
        name: 'Quick Games',
        description: 'Short activities that can be played in 10 minutes or less',
        iconPath: 'assets/icons/clock.svg',
        color: Colors.orange,
      ),
    ];
  }

  // Get a game suggestion
  Future<void> getGameSuggestion({
    int? numberOfPlayers,
    int? availableTimeMinutes,
    String? preferredCategory,
    String? additionalPreferences,
  }) async {
    try {
      isLoading.value = true;
      final suggestion = await _chatGptService.getGameSuggestion(
        numberOfPlayers: numberOfPlayers,
        availableTimeMinutes: availableTimeMinutes,
        preferredCategory: preferredCategory,
        additionalPreferences: additionalPreferences,
      );
      gameSuggestion.value = suggestion;
    } catch (e) {
      gameSuggestion.value = 'Error getting suggestion. Please try again later.';
    } finally {
      isLoading.value = false;
    }
  }

  // Get game of the day
  Future<void> getGameOfTheDay() async {
    try {
      final suggestion = await _chatGptService.getGameOfTheDay();
      gameOfTheDay.value = suggestion;
    } catch (e) {
      gameOfTheDay.value = 'Error getting game of the day. Please try again later.';
    }
  }

  // Get games by category
  List<Game> getGamesByCategory(String categoryId) {
    return games.where((game) => game.category.toLowerCase() == categoryId.toLowerCase()).toList();
  }

  // Get random game
  Game getRandomGame() {
    return _gameProvider.getRandomGame();
  }
}
