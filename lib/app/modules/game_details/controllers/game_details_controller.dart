import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/game_model.dart';
import '../../../data/services/gemini_api_service.dart';

class GameDetailsController extends GetxController {
  final Rx<Game?> game = Rx<Game?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingRules = false.obs;
  final GeminiApiService _geminiApiService = GeminiApiService();

  @override
  void onInit() {
    super.onInit();
    // Get game data from arguments
    if (Get.arguments != null && Get.arguments is Game) {
      game.value = Get.arguments as Game;
    }
  }

  // Method to generate outOfPlayRules using Gemini
  Future<void> generateOutOfPlayRules() async {
    if (game.value == null) return;

    try {
      isGeneratingRules.value = true;

      // Get outOfPlayRules from Gemini
      final outOfPlayRules = await _geminiApiService.getOutOfPlayRules(game.value!);

      if (outOfPlayRules.isNotEmpty) {
        // Create a new Game object with the updated outOfPlayRules
        final updatedGame = Game(
          id: game.value!.id,
          name: game.value!.name,
          description: game.value!.description,
          category: game.value!.category,
          imageUrl: game.value!.imageUrl,
          minPlayers: game.value!.minPlayers,
          maxPlayers: game.value!.maxPlayers,
          estimatedTimeMinutes: game.value!.estimatedTimeMinutes,
          instructions: game.value!.instructions,
          isFeatured: game.value!.isFeatured,
          difficultyLevel: game.value!.difficultyLevel,
          materialsRequired: game.value!.materialsRequired,
          gameType: game.value!.gameType,
          rating: game.value!.rating,
          isTimeBound: game.value!.isTimeBound,
          teamBased: game.value!.teamBased,
          rules: game.value!.rules,
          howToPlay: game.value!.howToPlay,
          winnerGamePlayerOrTeam: game.value!.winnerGamePlayerOrTeam,
          outOfPlayRules: outOfPlayRules,
        );

        // Update the game value in the controller
        game.value = updatedGame;

        // Save the updated game to the Hive box
        final gamesBox = await Hive.openBox<Game>('games');
        await gamesBox.put(updatedGame.id, updatedGame);

        Get.snackbar(
          'Success',
          'Out of Play Rules have been generated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to generate Out of Play Rules. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isGeneratingRules.value = false;
    }
  }
}
