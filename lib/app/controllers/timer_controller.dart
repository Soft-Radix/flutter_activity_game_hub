import 'dart:async';

import 'package:get/get.dart';

class TimerController extends GetxController {
  final RxInt seconds = 0.obs;
  final RxInt minutes = 0.obs;
  final RxBool isRunning = false.obs;
  final RxMap<String, int> scores = <String, int>{}.obs;

  Timer? _timer;

  // Start timer with given duration in minutes
  void startTimer(int durationMinutes) {
    // Reset timer
    resetTimer();

    // Set initial time
    minutes.value = durationMinutes;
    seconds.value = 0;

    isRunning.value = true;

    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (minutes.value == 0 && seconds.value == 0) {
        stopTimer();
        Get.snackbar(
          'Time\'s Up!',
          'The timer has reached zero.',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        if (seconds.value == 0) {
          minutes.value--;
          seconds.value = 59;
        } else {
          seconds.value--;
        }
      }
    });
  }

  // Pause the timer
  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  // Resume the timer
  void resumeTimer() {
    if (!isRunning.value) {
      isRunning.value = true;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (minutes.value == 0 && seconds.value == 0) {
          stopTimer();
          Get.snackbar(
            'Time\'s Up!',
            'The timer has reached zero.',
            snackPosition: SnackPosition.TOP,
          );
        } else {
          if (seconds.value == 0) {
            minutes.value--;
            seconds.value = 59;
          } else {
            seconds.value--;
          }
        }
      });
    }
  }

  // Stop the timer
  void stopTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  // Reset the timer
  void resetTimer() {
    _timer?.cancel();
    minutes.value = 0;
    seconds.value = 0;
    isRunning.value = false;
  }

  // Scoreboard functions

  // Initialize teams/players
  void initializeScores(List<String> teamOrPlayerNames) {
    scores.clear();
    for (final name in teamOrPlayerNames) {
      scores[name] = 0;
    }
  }

  // Increment score
  void incrementScore(String teamOrPlayerName) {
    if (scores.containsKey(teamOrPlayerName)) {
      scores[teamOrPlayerName] = (scores[teamOrPlayerName] ?? 0) + 1;
    }
  }

  // Decrement score
  void decrementScore(String teamOrPlayerName) {
    if (scores.containsKey(teamOrPlayerName)) {
      final currentScore = scores[teamOrPlayerName] ?? 0;
      if (currentScore > 0) {
        scores[teamOrPlayerName] = currentScore - 1;
      }
    }
  }

  // Set score
  void setScore(String teamOrPlayerName, int score) {
    if (scores.containsKey(teamOrPlayerName)) {
      scores[teamOrPlayerName] = score;
    }
  }

  // Reset all scores
  void resetScores() {
    for (final key in scores.keys) {
      scores[key] = 0;
    }
  }

  // Get winner (team with highest score)
  String? getWinner() {
    if (scores.isEmpty) return null;

    String? winner;
    int highestScore = -1;

    for (final entry in scores.entries) {
      if (entry.value > highestScore) {
        highestScore = entry.value;
        winner = entry.key;
      }
    }

    return winner;
  }

  // Check if there's a tie for the winner
  bool isTie() {
    if (scores.isEmpty) return false;

    final values = scores.values.toList();
    values.sort((a, b) => b.compareTo(a));

    // If the two highest scores are the same, there's a tie
    return values.length > 1 && values[0] == values[1];
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
