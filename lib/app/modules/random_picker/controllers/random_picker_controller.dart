import 'package:get/get.dart';

import '../../../data/models/game_model.dart';
import '../../../data/providers/gemini_game_provider.dart';

class RandomPickerController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<Game?> selectedGame = Rx<Game?>(null);
  final RxList<Game> availableGames = <Game>[].obs;
  final RxBool isAnimating = false.obs;

  // List to track previously shown games to avoid repetition
  final RxList<String> previouslyShownGameIds = <String>[].obs;

  // List of previously shown games objects to help with tracking
  final RxList<Game> previousGames = <Game>[].obs;

  // Maximum number of games to remember before resetting
  final int maxGameHistorySize = 20;

  // Track the last game's name to avoid repeating the same name
  String? lastGameName;

  @override
  void onInit() {
    super.onInit();
    _loadGames();
  }

  Future<void> _loadGames() async {
    isLoading.value = true;
    try {
      // We'll still load some games initially, but will get new ones from Gemini as needed
      final geminiGameProvider = Get.find<GeminiGameProvider>();
      final initialGames = await geminiGameProvider.getAllGames();
      availableGames.value = initialGames;
    } catch (e) {
      print('Error loading initial games: $e');
      Get.snackbar('Error', 'Failed to load initial games');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Game?> pickRandomGame() async {
    isAnimating.value = true;

    try {
      // Use Gemini API to get a single random game
      final geminiGameProvider = Get.find<GeminiGameProvider>();

      // Make multiple attempts to get a unique game
      int maxAttempts = 3;
      Game? randomGame;

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        // Get a random game from Gemini
        randomGame = await geminiGameProvider.getRandomGame();

        if (randomGame == null) {
          continue; // Try again if we got null
        }

        // Check if we've seen this game before (by ID or name)
        bool isDuplicate =
            previouslyShownGameIds.contains(randomGame.id) || lastGameName == randomGame.name;

        // If this is a new game, break out of the loop
        if (!isDuplicate) {
          break;
        }

        // If this is our last attempt and we still have a duplicate, use it anyway
        if (attempt == maxAttempts - 1) {
          // If we've accumulated too many games, clear history
          if (previouslyShownGameIds.length >= maxGameHistorySize) {
            previouslyShownGameIds.clear();
            previousGames.clear();
          }
        }
      }

      if (randomGame == null) {
        Get.snackbar('Error', 'No game returned from Gemini API');
        isAnimating.value = false;
        return null;
      }

      // Add to previously shown games
      previouslyShownGameIds.add(randomGame.id);
      previousGames.add(randomGame);
      lastGameName = randomGame.name;

      // Set the selected game
      selectedGame.value = randomGame;

      return randomGame;
    } catch (e) {
      print('Error picking random game from Gemini: $e');
      Get.snackbar('Error', 'Failed to get a game from Gemini AI');
      return null;
    } finally {
      isAnimating.value = false;
    }
  }

  void resetSelection() {
    selectedGame.value = null;
  }

  // Clear history of shown games
  void clearGameHistory() {
    previouslyShownGameIds.clear();
    previousGames.clear();
    lastGameName = null;
  }

  // Method to update available games
  void updateGames(List<Game> games) {
    availableGames.value = games;
  }
}
