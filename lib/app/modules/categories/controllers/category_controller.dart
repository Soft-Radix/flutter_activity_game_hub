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
  // For text search
  final searchController = TextEditingController();

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
}
