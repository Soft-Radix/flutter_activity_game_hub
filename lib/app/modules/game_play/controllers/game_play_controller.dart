import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/leaderboard_controller.dart';
import '../../../data/models/game_model.dart';

class GamePlayController extends GetxController {
  // Game data
  final game = Rx<Game?>(null);

  // Get leaderboard controller
  final LeaderboardController _leaderboardController = Get.find<LeaderboardController>();

  // Timer related variables
  final minutes = 0.obs;
  final seconds = 0.obs;
  final isRunning = false.obs;
  Timer? _timer;

  // Countdown for game start
  final countdownValue = 3.obs;
  final isCountingDown = false.obs;
  Timer? _countdownTimer;

  // Audio player for timer sounds - initialized lazily
  final _audioPlayer = AudioPlayer();
  final bool _soundEnabled = true; // Set to false to disable sounds

  // Player/participant management
  final players = <String>[].obs;
  final currentRound = 1.obs;
  final isAddingPlayers = false.obs;
  final newPlayerName = ''.obs;

  // Game progress tracking
  final isGameStarted = false.obs;
  final isGamePaused = false.obs;
  final isGameCompleted = false.obs;
  final isSetupCompleted = false.obs;

  // Game materials checklist
  final checkedMaterials = <String, bool>{}.obs;

  // Gameplay statistics for score calculation
  final startTime = Rx<DateTime?>(null);
  final endTime = Rx<DateTime?>(null);
  final gameScore = 0.obs;
  final playerName = 'You'.obs; // Default player name

  @override
  void onInit() {
    super.onInit();
    // Get the game data passed from previous screen
    if (Get.arguments != null && Get.arguments is Game) {
      game.value = Get.arguments;

      // Initialize materials checklist
      if (game.value != null) {
        for (String material in game.value!.materialsRequired) {
          checkedMaterials[material] = false;
        }
      }
    }
  }

  @override
  void onClose() {
    stopTimer();
    _stopCountdown();
    _audioPlayer.dispose();
    super.onClose();
  }

  // Timer functions
  void startTimer(int durationMinutes) {
    // Set the timer
    minutes.value = durationMinutes;
    seconds.value = 0;

    // Start the timer
    stopTimer(); // Make sure any existing timer is stopped
    isRunning.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else if (minutes.value > 0) {
        minutes.value--;
        seconds.value = 59;
      } else {
        // Timer completed
        stopTimer();
        _playTimerEndSound();
        _showTimerCompleteDialog();
      }

      // Play tick sound when timer is about to end (last 10 seconds)
      if (minutes.value == 0 && seconds.value <= 10 && seconds.value > 0) {
        _playTickSound();
      }
    });
  }

  void pauseTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      isRunning.value = false;
      isGamePaused.value = true;
      _playPauseSound();
    }
  }

  void resumeTimer() {
    if (!isRunning.value) {
      isRunning.value = true;
      isGamePaused.value = false;
      _playResumeSound();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (seconds.value > 0) {
          seconds.value--;
        } else if (minutes.value > 0) {
          minutes.value--;
          seconds.value = 59;
        } else {
          // Timer completed
          stopTimer();
          _playTimerEndSound();
          _showTimerCompleteDialog();
        }

        // Play tick sound when timer is about to end (last 10 seconds)
        if (minutes.value == 0 && seconds.value <= 10 && seconds.value > 0) {
          _playTickSound();
        }
      });
    }
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      isRunning.value = false;
    }
  }

  void resetTimer() {
    stopTimer();
    minutes.value = 0;
    seconds.value = 0;
  }

  // Countdown functions
  void startCountdown() {
    if (isCountingDown.value) return;

    isCountingDown.value = true;
    countdownValue.value = 3;

    _playCountdownSound();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownValue.value > 1) {
        countdownValue.value--;
        _playCountdownSound();
      } else {
        _stopCountdown();
        _playStartSound();
        // Actually start the game after countdown
        isGameStarted.value = true;

        // If the game is time-bound, start the timer
        if (game.value?.isTimeBound == true && game.value?.estimatedTimeMinutes != null) {
          startTimer(game.value!.estimatedTimeMinutes);
        }
      }
    });
  }

  void _stopCountdown() {
    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
      _countdownTimer = null;
      isCountingDown.value = false;
    }
  }

  // Player management
  void setAddingPlayers(bool value) {
    isAddingPlayers.value = value;
  }

  void updateNewPlayerName(String name) {
    newPlayerName.value = name;
  }

  void addPlayer(String name) {
    if (name.isNotEmpty && !players.contains(name)) {
      players.add(name);
      newPlayerName.value = '';
    }
  }

  void removePlayer(String name) {
    players.remove(name);
  }

  void clearAllPlayers() {
    players.clear();
  }

  // Material checklist
  void toggleMaterialChecked(String material) {
    if (checkedMaterials.containsKey(material)) {
      checkedMaterials[material] = !checkedMaterials[material]!;
    }
  }

  bool areAllMaterialsChecked() {
    return !checkedMaterials.values.contains(false);
  }

  void completeSetup() {
    isSetupCompleted.value = true;
    startCountdown();
  }

  // Game control
  void startGame() {
    if (players.isEmpty && (game.value?.minPlayers ?? 0) > 0) {
      Get.snackbar(
        'Players Required',
        'Please add at least ${game.value?.minPlayers} player(s) before starting the game',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (areAllMaterialsChecked()) {
      // Record game start time
      startTime.value = DateTime.now();
      completeSetup();
    } else {
      Get.snackbar(
        'Materials Required',
        'Please check all required materials before starting the game',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void pauseGame() {
    pauseTimer();
    isGamePaused.value = true;
  }

  void resumeGame() {
    resumeTimer();
    isGamePaused.value = false;
  }

  void completeGame() {
    stopTimer();
    isGameCompleted.value = true;

    // Record game end time
    endTime.value = DateTime.now();

    // Calculate score
    calculateGameScore();

    // Save game history to leaderboard
    _saveGameHistory();

    // Play sound effect
    _playGameCompleteSound();

    // Show completion dialog with score
    _showGameCompleteDialog();
  }

  // Save game history
  Future<void> _saveGameHistory() async {
    if (game.value == null) return;

    try {
      final String playerName = players.isNotEmpty ? players.first : this.playerName.value;

      await _leaderboardController.addEntry(
        playerOrTeamName: playerName,
        gameId: game.value!.id,
        gameName: game.value!.name,
        score: gameScore.value,
      );

      debugPrint(
        'Game history saved successfully for player: $playerName, game: ${game.value!.name}, score: ${gameScore.value}',
      );
    } catch (e) {
      debugPrint('Error saving game history: $e');
      // Show error to user
      Get.snackbar(
        'Error Saving Game',
        'There was a problem saving your game to history. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Add score to leaderboard
  Future<void> addScoreToLeaderboard() async {
    if (game.value == null) return;

    try {
      // This is now handled by _saveGameHistory
      // But we keep this to show feedback to user
      Get.snackbar(
        'Game History Saved',
        'Your game play has been added to your history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error showing game history feedback: $e');
      Get.snackbar(
        'Error',
        'Failed to save your game to history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void nextRound() {
    currentRound.value++;
    _playNextRoundSound();
  }

  void resetGame() {
    stopTimer();
    isGameStarted.value = false;
    isGamePaused.value = false;
    isGameCompleted.value = false;
    isSetupCompleted.value = false;
    currentRound.value = 1;

    // Reset materials checklist
    for (String key in checkedMaterials.keys) {
      checkedMaterials[key] = false;
    }
  }

  // Sound effects
  void _playTickSound() {
    if (!_soundEnabled) return;
    _audioPlayer.play(AssetSource('sounds/tick.wav'), volume: 0.3).catchError((error) {
      // Handle errors silently
      debugPrint('Error playing sound: $error');
    });
  }

  void _playTimerEndSound() {
    if (!_soundEnabled) return;
    _playBeep(800, 500);
  }

  void _playPauseSound() {
    if (!_soundEnabled) return;
    _playBeep(400, 200);
  }

  void _playResumeSound() {
    if (!_soundEnabled) return;
    _playBeep(600, 200);
  }

  void _playCountdownSound() {
    if (!_soundEnabled) return;
    _playBeep(440, 200);
  }

  void _playStartSound() {
    if (!_soundEnabled) return;
    _playBeep(880, 300);
  }

  void _playGameCompleteSound() {
    if (!_soundEnabled) return;
    _playBeep(660, 500);
  }

  void _playNextRoundSound() {
    if (!_soundEnabled) return;
    _playBeep(550, 200);
  }

  // Helper for playing basic sounds (frequency in Hz, duration in ms)
  Future<void> _playBeep(int frequency, int duration) async {
    try {
      await _audioPlayer.setSourceUrl('https://www.soundjay.com/button/beep-1.mp3');
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Failed to play sound: $e');
    }
  }

  // Dialog functions
  void _showTimerCompleteDialog() {
    // Record game end time and calculate score
    endTime.value = DateTime.now();
    calculateGameScore();

    // Save game history
    _saveGameHistory();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            const Text('Time\'s Up!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('The game timer has ended.'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '${gameScore.value}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This game has been saved to your history.',
                      style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Continue Playing')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              isGameCompleted.value = true;
              viewGameHistory();
            },
            icon: const Icon(Icons.history),
            label: const Text('View Game History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showGameCompleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            const Text('Game Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '${gameScore.value}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Congratulations! You\'ve completed the game.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This game has been saved to your history.',
                      style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Return to game details
            },
            child: const Text('Return to Game'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              viewGameHistory();
            },
            icon: const Icon(Icons.history),
            label: const Text('View Game History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Calculate game score based on various factors
  void calculateGameScore() {
    if (game.value == null || startTime.value == null) return;

    final Random random = Random();
    int baseScore = 100; // Base score for completing a game

    // Add difficulty bonus
    switch (game.value!.difficultyLevel) {
      case 'Easy':
        baseScore += 20;
        break;
      case 'Medium':
        baseScore += 50;
        break;
      case 'Hard':
        baseScore += 80;
        break;
    }

    // Add time bonus for time-bound games (faster completion = higher score)
    if (game.value!.isTimeBound && startTime.value != null && endTime.value != null) {
      final int allocatedTimeSeconds = game.value!.estimatedTimeMinutes * 60;
      final int actualTimeSeconds = endTime.value!.difference(startTime.value!).inSeconds;

      // If completed faster than allocated time, add bonus
      if (actualTimeSeconds < allocatedTimeSeconds) {
        final int timeBonus = ((allocatedTimeSeconds - actualTimeSeconds) / 10).floor();
        baseScore += min(timeBonus, 100); // Cap time bonus at 100 points
      }
    }

    // Add small random factor for variety
    baseScore += random.nextInt(20);

    // Store the calculated score
    gameScore.value = baseScore;
  }

  // Navigate to game history
  void viewGameHistory() {
    if (game.value == null) return;

    Get.toNamed('/leaderboard', arguments: {'gameId': game.value!.id});
  }
}
