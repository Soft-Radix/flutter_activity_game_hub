import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/category_model.dart';
import '../data/models/chatgpt_suggestion_model.dart';
import '../data/models/game_model.dart';
import '../data/providers/chatgpt_provider.dart';
import '../data/providers/game_provider.dart';
import '../services/chatgpt_service.dart';

class AppController extends GetxController {
  final GameProvider _gameProvider = Get.find<GameProvider>();
  final ChatGptService _chatGptService = Get.find<ChatGptService>();
  final ChatGptProvider _chatGptProvider = Get.find<ChatGptProvider>();

  // Observable variables
  final RxList<Game> games = <Game>[].obs;
  final RxList<Game> featuredGames = <Game>[].obs;
  final RxList<GameCategory> categories = <GameCategory>[].obs;
  final Rx<ChatGptSuggestion?> currentGameSuggestion = Rx<ChatGptSuggestion?>(null);
  final Rx<ChatGptSuggestion?> gameOfTheDay = Rx<ChatGptSuggestion?>(null);
  final RxList<ChatGptSuggestion> savedSuggestions = <ChatGptSuggestion>[].obs;
  final Rx<GameCategory?> selectedCategory = Rx<GameCategory?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGames();
    loadCategories();
    loadSavedSuggestions();
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

  // Load saved suggestions
  void loadSavedSuggestions() {
    try {
      // Load game suggestions
      final gameSuggestions = _chatGptProvider.getAllSuggestionsByType(
        SuggestionType.gameSuggestion,
      );
      savedSuggestions.value = gameSuggestions;

      // Set current game suggestion from cache if available
      if (gameSuggestions.isNotEmpty) {
        currentGameSuggestion.value = gameSuggestions.first;
      }

      // Load game of the day from cache if available
      final gameOfDaySuggestions = _chatGptProvider.getAllSuggestionsByType(
        SuggestionType.gameOfTheDay,
      );
      if (gameOfDaySuggestions.isNotEmpty) {
        gameOfTheDay.value = gameOfDaySuggestions.first;
      }
    } catch (e) {
      print('Error loading saved suggestions: $e');
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

      currentGameSuggestion.value = suggestion;

      // Add to saved suggestions if not already there
      if (!savedSuggestions.any((s) => s.id == suggestion.id)) {
        savedSuggestions.insert(0, suggestion);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get game suggestion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      print('Error getting game of the day: $e');
    }
  }

  // Send a custom query to ChatGPT
  Future<ChatGptSuggestion> sendCustomQuery(String query) async {
    try {
      final response = await _chatGptService.customQuery(query);
      return response;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process your query: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Return a default error suggestion
      return ChatGptSuggestion.fromResponse(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        content: 'Sorry, there was an error processing your query.',
        type: SuggestionType.customQuery,
      );
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

  // Convert a ChatGPT suggestion to a playable Game
  Game? convertSuggestionToGame(ChatGptSuggestion suggestion) {
    try {
      final parsedDetails = suggestion.parseGameDetails();

      // If we couldn't parse a game name, don't create a game
      if (parsedDetails['name'] == null) return null;

      // Create a game object from the suggestion
      final game = Game(
        id: 'ai_${suggestion.id}',
        name: parsedDetails['name']!,
        description: parsedDetails['description'] ?? 'No description available',
        category: 'AI-Generated',
        imageUrl: 'assets/images/placeholder.svg',
        minPlayers: 2,
        maxPlayers: 20,
        estimatedTimeMinutes: 20,
        instructions: _parseInstructions(parsedDetails['instructions'] ?? ''),
        isFeatured: false,
      );

      return game;
    } catch (e) {
      print('Error converting suggestion to game: $e');
      return null;
    }
  }

  // Add a suggested game to the game library
  Future<bool> addSuggestedGameToLibrary(ChatGptSuggestion suggestion) async {
    final game = convertSuggestionToGame(suggestion);
    if (game != null) {
      try {
        await _gameProvider.addGame(game);
        await loadGames(); // Refresh the games list
        return true;
      } catch (e) {
        print('Error adding game to library: $e');
        return false;
      }
    }
    return false;
  }

  // Helper method to parse instructions from text
  List<String> _parseInstructions(String instructionsText) {
    // Try to detect numbered list (1. xxx, 2. xxx)
    final regexNumbered = RegExp(r'(\d+\s*\.?\s*[^\n.]+)');
    final numberedMatches = regexNumbered.allMatches(instructionsText);

    if (numberedMatches.isNotEmpty) {
      return numberedMatches.map((m) => m.group(0)!.trim()).toList();
    }

    // Try to detect bullet points (• xxx, - xxx, * xxx)
    final regexBullets = RegExp(r'([•\-*]\s*[^\n•\-*]+)');
    final bulletMatches = regexBullets.allMatches(instructionsText);

    if (bulletMatches.isNotEmpty) {
      return bulletMatches.map((m) => m.group(0)!.trim()).toList();
    }

    // If no list format detected, split by periods or new lines
    final sentences =
        instructionsText
            .split(RegExp(r'(?<=\.)\s+|\n+'))
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.trim())
            .toList();

    return sentences.isEmpty ? ['No instructions available'] : sentences;
  }

  // Delete a suggestion
  Future<void> deleteSuggestion(ChatGptSuggestion suggestion) async {
    try {
      await _chatGptProvider.deleteSuggestion(suggestion.id);
      // Remove from local list
      savedSuggestions.removeWhere((s) => s.id == suggestion.id);

      // If it was the current suggestion, set to null
      if (currentGameSuggestion.value?.id == suggestion.id) {
        currentGameSuggestion.value = null;
      }

      // If it was the game of the day, set to null
      if (gameOfTheDay.value?.id == suggestion.id) {
        gameOfTheDay.value = null;
      }

      Get.snackbar(
        'Success',
        'Suggestion deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete suggestion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}
