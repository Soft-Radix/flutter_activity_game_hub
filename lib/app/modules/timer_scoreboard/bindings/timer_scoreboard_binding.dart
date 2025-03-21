import 'package:get/get.dart';

import '../controllers/timer_scoreboard_controller.dart';

class TimerScoreboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimerScoreboardController>(() => TimerScoreboardController());
  }
}
