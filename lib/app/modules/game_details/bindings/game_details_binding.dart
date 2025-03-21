import 'package:get/get.dart';

import '../controllers/game_details_controller.dart';

class GameDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameDetailsController>(() => GameDetailsController());
  }
}
