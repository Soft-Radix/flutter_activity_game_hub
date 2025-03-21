import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/game_model.dart';

class GamePlayController extends GetxController {
  // Game data
  final game = Rx<Game?>(null);

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
    // Navigate to results or leaderboard if needed
    _playGameCompleteSound();
    _showGameCompleteDialog();
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
    Get.dialog(
      AlertDialog(
        title: const Text('Time\'s Up!'),
        content: const Text('The timer has completed.'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('OK'))],
      ),
    );
  }

  void _showGameCompleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Game Completed'),
        content: const Text('You have completed the game!'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Return to game details screen
            },
            child: const Text('Return to Game'),
          ),
        ],
      ),
    );
  }
}
