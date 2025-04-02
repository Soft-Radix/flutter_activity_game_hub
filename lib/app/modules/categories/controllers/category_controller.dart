import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/gemini_app_controller.dart';
import '../../../data/models/game_model.dart';
import '../../../data/providers/game_provider.dart';
import '../../../data/services/featured_game_service.dart';

class CategoryController extends GetxController {
  // References to other controllers
  final GameProvider _gameProvider = Get.find<GameProvider>();
  final FeaturedGameService _featuredGameService = Get.find<FeaturedGameService>();
  final GeminiAppController _geminiController = Get.find<GeminiAppController>();
  final RxBool isLoading = false.obs;
  final RxList<Game> games = <Game>[].obs;
  final RxBool isGeminiMode = false.obs;
  // For text search
  final searchController = TextEditingController();
  final RxList<String> searchSuggestions = <String>[].obs;

  // Pagination variables
  final RxList<Game> searchResults = <Game>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreResults = true.obs;
  final int pageSize = 5;
  final RxInt currentPage = 1.obs;
  final RxString lastSearchQuery = "".obs;

  // Added for random category games
  final RxList<Game> categoryGames = <Game>[].obs;
  final RxBool isLoadingCategoryGames = false.obs;
  final RxBool hasMoreCategoryGames = true.obs;
  final RxInt categoryCurrentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadGames();
    // Add listener to ensure UI updates on hot restart
    ever(games, (_) => update(['filteredGames']));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load random games based on category title
  Future<void> loadGamesByTitle(String title, {bool resetPagination = true}) async {
    debugPrint('Loading games for category: $title with pageSize: $pageSize');

    if (resetPagination) {
      isLoadingCategoryGames.value = true;
      categoryCurrentPage.value = 1;
      categoryGames.clear();
    } else {
      isLoadingMore.value = true;
    }

    try {
      // Request more games for the Ice Breakers category specifically
      final actualPageSize = title.contains('Ice Breaker') ? 15 : pageSize;

      final results = await _geminiController.getGamesByCategory(
        title,
        pageSize: actualPageSize,
        page: categoryCurrentPage.value,
      );

      if (results.isEmpty) {
        hasMoreCategoryGames.value = false;
        debugPrint('No games found for category: $title');
      } else {
        categoryGames.addAll(results);
        categoryCurrentPage.value++;
        hasMoreCategoryGames.value = results.length >= actualPageSize;
        debugPrint(
          'Loaded ${results.length} games for category: $title. Total: ${categoryGames.length}',
        );
      }

      refreshUI();
    } catch (e) {
      debugPrint('Error loading category games: $e');
    } finally {
      isLoadingCategoryGames.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more category games when user reaches end of list
  Future<void> loadMoreCategoryGames(String title) async {
    if (!isLoadingMore.value && hasMoreCategoryGames.value) {
      await loadGamesByTitle(title, resetPagination: false);
    }
  }

  // Load all games
  Future<void> loadGames() async {
    isLoading.value = true;
    try {
      // Load regular games
      games.value = _gameProvider.getAllGames();
      debugPrint('Games loaded: ${games.length}');
      // Force update on all UI components
      refreshUI();
    } catch (e) {
      debugPrint('Error loading games: $e');
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

  // Get game list for display - all games since we're not filtering by category
  List<Game> getGamesForDisplay() {
    return games;
  }

  // Force UI to refresh after hot restart
  void refreshUI() {
    update(['filteredGames', 'suggestions']);
  }

  // Fetch search suggestions from Gemini API
  Future<void> fetchSuggestions(String query, {String screenTitle = 'Games'}) async {
    if (query.isEmpty) {
      searchSuggestions.clear();
      return;
    }

    try {
      // Create a more contextualized query with the screen title
      String contextualQuery = screenTitle != 'Games' ? '$screenTitle related to $query' : query;

      // Get suggestions from Gemini API with context
      final suggestions = await _geminiController.getSuggestions(contextualQuery);

      // Update suggestions list
      searchSuggestions.value = suggestions;

      debugPrint(
        'Fetched ${suggestions.length} suggestions for "$query" in category "$screenTitle"',
      );
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      // Clear suggestions on error
      searchSuggestions.clear();
    }
  }

  // Search games with text and pagination
  Future<void> searchGames(String query, {bool resetPagination = true}) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    if (resetPagination) {
      isLoading.value = true;
      currentPage.value = 1;
      searchResults.clear();
      lastSearchQuery.value = query;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final results = await _geminiController.getGamesByCategory(
        query,
        pageSize: pageSize,
        page: currentPage.value,
      );

      if (results.isEmpty) {
        hasMoreResults.value = false;
      } else {
        searchResults.addAll(results);
        currentPage.value++;
        hasMoreResults.value = results.length >= pageSize;
      }

      refreshUI();
    } catch (e) {
      debugPrint('Error searching games: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more search results when user reaches end of list
  Future<void> loadMoreResults() async {
    if (!isLoadingMore.value && hasMoreResults.value) {
      await searchGames(lastSearchQuery.value, resetPagination: false);
    }
  }
}
