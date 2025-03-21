import 'dart:async';

import 'package:get/get.dart';

class TimerScoreboardController extends GetxController {
  final RxInt seconds = 0.obs;
  final RxInt minutes = 0.obs;
  final RxBool isRunning = false.obs;
  final RxMap<String, int> scores = <String, int>{}.obs;
  final RxList<String> teams = <String>[].obs;

  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer(int durationMinutes) {
    resetTimer();
    minutes.value = durationMinutes;
    seconds.value = 0;
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

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void resumeTimer() {
    if (!isRunning.value) {
      startTimer(minutes.value);
    }
  }

  void stopTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void resetTimer() {
    _timer?.cancel();
    minutes.value = 0;
    seconds.value = 0;
    isRunning.value = false;
  }

  void addTeam(String teamName) {
    if (!teams.contains(teamName)) {
      teams.add(teamName);
      scores[teamName] = 0;
    }
  }

  void removeTeam(String teamName) {
    teams.remove(teamName);
    scores.remove(teamName);
  }

  void incrementScore(String teamName) {
    if (scores.containsKey(teamName)) {
      scores[teamName] = scores[teamName]! + 1;
    }
  }

  void decrementScore(String teamName) {
    if (scores.containsKey(teamName) && scores[teamName]! > 0) {
      scores[teamName] = scores[teamName]! - 1;
    }
  }

  void resetScores() {
    for (var team in teams) {
      scores[team] = 0;
    }
  }
}
