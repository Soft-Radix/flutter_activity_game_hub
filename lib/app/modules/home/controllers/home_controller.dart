import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/game_model.dart';
import '../../../data/providers/game_provider.dart';
import '../../../data/services/featured_game_service.dart';
import '../../../modules/random_picker/controllers/random_picker_controller.dart';

class HomeController extends GetxService {
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
  final RxList<Game> featuredGamesQueue = <Game>[].obs; // Queue of featured games
  final RxInt currentFeaturedGameIndex = 0.obs; // Current index in the featured games list
  final RxList<GameCategory> categories = <GameCategory>[].obs;
  final Rx<GameCategory?> selectedCategory = Rx<GameCategory?>(null);

  // Timer for rotating through featured games
  Timer? _featuredGameRotationTimer;

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

    // Start a timer for rotating through games, but don't refresh on start
    if (featuredServiceAvailable.value) {
      // Load cached games queue first instead of making API call
      _loadCachedGamesQueue();
      _startFeaturedGameRotation();
    }
  }

  @override
  void onClose() {
    // Cancel any timers when the controller is closed
    if (featuredServiceAvailable.value) {
      try {
        debugPrint('🛑 Stopping auto-refresh timers on HomeController close');
        _featuredGameService.refreshTimer?.cancel();
        _featuredGameRotationTimer?.cancel();
      } catch (e) {
        debugPrint('❌ Error stopping timers: $e');
      }
    }
    super.onClose();
  }

  // Start the timer for rotating through featured games
  void _startFeaturedGameRotation() {
    _featuredGameRotationTimer?.cancel();
    _featuredGameRotationTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _rotateToNextFeaturedGame();
    });
  }

  // Rotate to the next featured game
  void _rotateToNextFeaturedGame() {
    if (featuredGamesQueue.isEmpty) return;

    currentFeaturedGameIndex.value++;

    // If we've reached the end of our list, fetch more games
    if (currentFeaturedGameIndex.value >= featuredGamesQueue.length) {
      debugPrint('🔄 Reached end of games queue, fetching more games from API');
      currentFeaturedGameIndex.value = 0; // Reset to beginning
      _refreshFeaturedGameSilently(); // Only fetch more games when we've gone through the queue
    } else {
      // If we still have games in the queue, just rotate to the next one
      debugPrint(
        '🔄 Rotating to next game in queue (${currentFeaturedGameIndex.value + 1}/${featuredGamesQueue.length})',
      );
    }

    // Update the displayed featured game
    if (featuredGamesQueue.isNotEmpty) {
      featuredGames.value = [featuredGamesQueue[currentFeaturedGameIndex.value]];
    }
  }

  // Load cached games queue from storage
  Future<void> _loadCachedGamesQueue() async {
    try {
      // First try to load the entire queue
      final cachedQueue = await _featuredGameService.loadGamesQueue();
      if (cachedQueue.isNotEmpty) {
        featuredGamesQueue.value = cachedQueue;
        featuredGames.value = [cachedQueue.first];
        debugPrint('✅ Loaded ${cachedQueue.length} games from queue cache');
        return;
      }

      // If no queue, try to get individual cached game
      final cachedGame = await _featuredGameService.getCachedGameWithoutRefresh();
      if (cachedGame != null) {
        // If we have a cached game, use it without making API call
        featuredGames.value = [cachedGame];

        // Add to queue if it's empty
        if (!featuredGamesQueue.any((game) => game.id == cachedGame.id)) {
          featuredGamesQueue.add(cachedGame);
          _saveGamesQueue();
        }

        debugPrint('✅ Loaded cached game without API call: ${cachedGame.name}');
      } else {
        // Only if we don't have any cached games, make an API call
        debugPrint('⚠️ No cached games found, will need to fetch from API');
        _refreshFeaturedGameSilently();
      }
    } catch (e) {
      debugPrint('❌ Error loading cached games queue: $e');
    }
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
        // Add the game to our queue if it's not already there
        if (!featuredGamesQueue.any((game) => game.id == refreshedGame.id)) {
          featuredGamesQueue.add(refreshedGame);

          // Save the updated queue
          _saveGamesQueue();
        }

        // If this is our first game, display it immediately
        if (featuredGamesQueue.length == 1) {
          featuredGames.value = [refreshedGame];
        }
      }
    } catch (e) {
      debugPrint('❌ Silent refresh failed: $e');
    }
  }

  // Save the games queue to persistent storage
  Future<void> _saveGamesQueue() async {
    try {
      await _featuredGameService.saveGamesQueue(featuredGamesQueue);
      debugPrint('✅ Saved games queue with ${featuredGamesQueue.length} games');
    } catch (e) {
      debugPrint('❌ Error saving games queue: $e');
    }
  }

  // Load all games
  Future<void> loadGames() async {
    isLoading.value = true;
    try {
      games.value = _gameProvider.getAllGames();

      // Check if we already have a games queue loaded
      if (featuredGamesQueue.isNotEmpty && featuredGames.isNotEmpty) {
        debugPrint('✅ Using existing featured games queue');
        isLoading.value = false;
        return;
      }

      // Load featured game from cache if available
      if (featuredServiceAvailable.value) {
        try {
          debugPrint('🔄 Loading featured game in HomeController');
          // Try to get game from cache first without API call
          final featuredGame = await _featuredGameService.getCachedGameWithoutRefresh();

          if (featuredGame != null) {
            debugPrint('✅ Got featured game from cache: ${featuredGame.name}');
            featuredGames.value = [featuredGame];

            // Initialize our featured games queue with this game
            if (!featuredGamesQueue.any((game) => game.id == featuredGame.id)) {
              featuredGamesQueue.add(featuredGame);
            }

            // Only fetch more games if we have less than 3 in the queue
            if (featuredGamesQueue.length < 3) {
              _fetchMoreFeaturedGames(silent: true);
            }
          } else {
            debugPrint('⚠️ No cached game, using API');
            // If no valid cache, make API call
            final newGame = await _featuredGameService.getFeaturedGameOfTheDay();

            if (newGame != null) {
              featuredGames.value = [newGame];
              featuredGamesQueue.add(newGame);
              _fetchMoreFeaturedGames(silent: true);
            } else {
              // Fall back to local featured games
              final localFeaturedGames = _gameProvider.getFeaturedGames();
              featuredGames.value = localFeaturedGames.isNotEmpty ? [localFeaturedGames.first] : [];
              featuredGamesQueue.value = localFeaturedGames;
            }
          }
        } catch (e) {
          debugPrint('❌ Error loading featured game in HomeController: $e');
          // Fall back to local featured games
          final localFeaturedGames = _gameProvider.getFeaturedGames();
          featuredGames.value = localFeaturedGames.isNotEmpty ? [localFeaturedGames.first] : [];
          featuredGamesQueue.value = localFeaturedGames;
        }
      } else {
        debugPrint('⚠️ FeaturedGameService not available, using local games');
        // If service isn't available, use local games
        final localFeaturedGames = _gameProvider.getFeaturedGames();
        featuredGames.value = localFeaturedGames.isNotEmpty ? [localFeaturedGames.first] : [];
        featuredGamesQueue.value = localFeaturedGames;
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

  // Fetch more featured games to populate our queue
  Future<void> _fetchMoreFeaturedGames({bool silent = false}) async {
    if (!featuredServiceAvailable.value) return;
    if (!silent) isLoading.value = true;

    try {
      // Try to get multiple featured games (up to 3)
      for (int i = 0; i < 3; i++) {
        final game = await _featuredGameService.refreshFeaturedGame();
        if (game != null && !featuredGamesQueue.any((existing) => existing.id == game.id)) {
          featuredGamesQueue.add(game);
          _saveGamesQueue();
          debugPrint('✅ Added game to queue: ${game.name}');
        }
        // Short delay to avoid hammering the API
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('❌ Error fetching more featured games: $e');
    } finally {
      if (!silent) isLoading.value = false;
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
