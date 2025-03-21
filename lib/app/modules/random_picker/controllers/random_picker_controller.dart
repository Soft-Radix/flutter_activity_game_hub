import 'dart:math';

import 'package:get/get.dart';

import '../../../data/models/game_model.dart';
import '../../../data/providers/game_provider.dart';

class RandomPickerController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<Game?> selectedGame = Rx<Game?>(null);
  final RxList<Game> availableGames = <Game>[].obs;
  final RxBool isAnimating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadGames();
  }

  Future<void> _loadGames() async {
    isLoading.value = true;
    try {
      // Load games from GameProvider
      final gameProvider = Get.find<GameProvider>();
      availableGames.value = gameProvider.getAllGames();
    } catch (e) {
      print('Error loading games: $e');
      Get.snackbar('Error', 'Failed to load games');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Game?> pickRandomGame() async {
    if (availableGames.isEmpty) {
      Get.snackbar('Error', 'No games available to pick from');
      return null;
    }

    isAnimating.value = true;

    // Simulate animation time
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final randomIndex = random.nextInt(availableGames.length);
    selectedGame.value = availableGames[randomIndex];

    isAnimating.value = false;
    return selectedGame.value;
  }

  void resetSelection() {
    selectedGame.value = null;
  }

  // Method to update available games
  void updateGames(List<Game> games) {
    availableGames.value = games;
  }
}
