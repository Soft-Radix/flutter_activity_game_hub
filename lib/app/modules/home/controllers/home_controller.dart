import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/game_model.dart';
import '../../../data/providers/game_provider.dart';
import '../../../data/services/featured_game_service.dart';
import '../../../modules/random_picker/controllers/random_picker_controller.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final GameProvider _gameProvider = Get.find<GameProvider>();
  final RandomPickerController _randomPickerController = Get.find<RandomPickerController>();

  // Get FeaturedGameService with error handling
  late final FeaturedGameService _featuredGameService;
  final RxBool featuredServiceAvailable = false.obs;
  final RxBool isAutoRefreshEnabled = true.obs;

  // Observable variables
  final RxList<Game> games = <Game>[].obs;
  final RxList<Game> featuredGames = <Game>[].obs;
  final RxList<GameCategory> categories = <GameCategory>[].obs;
  final Rx<GameCategory?> selectedCategory = Rx<GameCategory?>(null);

  @override
  void onInit() {
    super.onInit();

    // Safely get the FeaturedGameService
    try {
      _featuredGameService = Get.find<FeaturedGameService>();
      featuredServiceAvailable.value = true;
      debugPrint('✅ FeaturedGameService found in HomeController');
    } catch (e) {
      debugPrint('❌ Failed to find FeaturedGameService in HomeController: $e');
      featuredServiceAvailable.value = false;
    }

    loadGames();
    loadCategories();

    // Start an initial refresh to ensure we have the latest game
    if (featuredServiceAvailable.value) {
      debugPrint('🔄 Initiating initial featured game refresh on app start');
      _refreshFeaturedGameSilently();
    }
  }

  @override
  void onClose() {
    // Cancel any timers when the controller is closed
    if (featuredServiceAvailable.value) {
      try {
        debugPrint('🛑 Stopping auto-refresh timers on HomeController close');
        _featuredGameService.refreshTimer?.cancel();
      } catch (e) {
        debugPrint('❌ Error stopping timers: $e');
      }
    }
    super.onClose();
  }

  // Silently refresh the featured game without UI notifications
  Future<void> _refreshFeaturedGameSilently() async {
    if (!featuredServiceAvailable.value || !isAutoRefreshEnabled.value) {
      return;
    }

    try {
      debugPrint('🔄 Silent featured game refresh in progress...');
      final refreshedGame = await _featuredGameService.refreshFeaturedGame();

      if (refreshedGame != null) {
        debugPrint('✅ Silent refresh successful, updating featured game');
        featuredGames.value = [refreshedGame];
      }
    } catch (e) {
      debugPrint('❌ Silent refresh failed: $e');
    }
  }

  // Load all games
  Future<void> loadGames() async {
    isLoading.value = true;
    try {
      games.value = _gameProvider.getAllGames();

      // Load featured game from Gemini API with 4-hour cache if available
      if (featuredServiceAvailable.value) {
        try {
          debugPrint('🔄 Loading featured game in HomeController');
          final featuredGame = await _featuredGameService.getFeaturedGameOfTheDay();
          isLoading.value = false;
          if (featuredGame != null) {
            debugPrint('✅ Got featured game: ${featuredGame.name}');
            // If we got a game from the API, use it
            featuredGames.value = [featuredGame];
          } else {
            debugPrint('⚠️ No featured game from API, using local');
            // If the API fails, fall back to local featured games
            featuredGames.value = _gameProvider.getFeaturedGames();
          }
        } catch (e) {
          debugPrint('❌ Error loading featured game in HomeController: $e');
          // Fall back to local featured games
          featuredGames.value = _gameProvider.getFeaturedGames();
        }
      } else {
        debugPrint('⚠️ FeaturedGameService not available, using local games');
        // If service isn't available, use local games
        featuredGames.value = _gameProvider.getFeaturedGames();
      }

      // Update the games in the RandomPickerController as well
      _randomPickerController.updateGames(games);
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

  // Get games by category
  List<Game> getGamesByCategory(String categoryId) {
    return games.where((game) => game.category.toLowerCase() == categoryId.toLowerCase()).toList();
  }

  // Get random game
  Game? getRandomGame() {
    return _randomPickerController.pickRandomGame() as Game?;
  }

  // Set selected category and update RandomPickerController
  void setSelectedCategory(GameCategory category) {
    selectedCategory.value = category;

    // Update the games in the RandomPickerController to match this category
    final gamesForCategory = getGamesByCategory(category.id);
    _randomPickerController.updateGames(gamesForCategory);
  }
}
