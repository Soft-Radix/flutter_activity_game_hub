import 'package:get/get.dart';

import '../../../controllers/leaderboard_controller.dart';
import '../controllers/game_play_controller.dart';

class GamePlayBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure LeaderboardController is available
    if (!Get.isRegistered<LeaderboardController>()) {
      Get.lazyPut<LeaderboardController>(() => LeaderboardController(), fenix: true);
    }

    Get.lazyPut<GamePlayController>(() => GamePlayController());
  }
}
