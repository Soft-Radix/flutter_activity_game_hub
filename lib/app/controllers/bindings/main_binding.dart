import 'package:activity_game_hub_flutter/app/modules/settings/controllers/settings_controller.dart';
import 'package:get/get.dart';

import '../../data/providers/game_provider.dart';
import '../../data/providers/gemini_game_provider.dart';
import '../../data/services/gemini_api_service.dart';
import '../../modules/categories/controllers/category_controller.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/random_picker/controllers/random_picker_controller.dart';
import '../gemini_app_controller.dart';
import '../navigation_controller.dart';

import '../theme_controller.dart';
import '../leaderboard_controller.dart';


class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.putAsync<GameProvider>(() async => await GameProvider().init());
    Get.putAsync<GeminiGameProvider>(() async => await GeminiGameProvider().init());

    // Services
    Get.put(GeminiApiService());

    // Controllers
    Get.lazyPut<GeminiAppController>(() => GeminiAppController(), fenix: true);
    Get.lazyPut<NavigationController>(() => NavigationController(), fenix: true);
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<LeaderboardController>(() => LeaderboardController(), fenix: true);

    // Add our new CategoryController
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    // Add RandomPickerController globally with fenix: true to keep it alive
    Get.lazyPut<RandomPickerController>(() => RandomPickerController(), fenix: true);
  }
}
