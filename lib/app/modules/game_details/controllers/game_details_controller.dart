import 'package:get/get.dart';

import '../../../data/models/game_model.dart';

class GameDetailsController extends GetxController {
  final Rx<Game?> game = Rx<Game?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get game data from arguments
    if (Get.arguments != null && Get.arguments is Game) {
      game.value = Get.arguments as Game;
    }
  }
}
