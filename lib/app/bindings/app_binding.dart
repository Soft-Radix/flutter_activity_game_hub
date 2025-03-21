import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/gemini_app_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';
import '../data/providers/game_provider.dart';
import '../data/providers/gemini_game_provider.dart';
import '../data/services/featured_game_service.dart';
import '../data/services/gemini_api_service.dart';
import '../modules/categories/controllers/category_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/random_picker/controllers/random_picker_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔄 Starting AppBinding.dependencies()');

    // Register GeminiApiService and FeaturedGameService first
    try {
      debugPrint('📥 Registering GeminiApiService');
      Get.put<GeminiApiService>(GeminiApiService(), permanent: true);

      debugPrint('📥 Registering FeaturedGameService');
      Get.put<FeaturedGameService>(FeaturedGameService(), permanent: true);
      debugPrint('✅ FeaturedGameService registered successfully');
    } catch (e) {
      debugPrint('❌ Error registering services: $e');
    }

    // For services that need async initialization, use putAsync
    try {
      debugPrint('📥 Registering async services');
      Get.putAsync<GameProvider>(() => GameProvider().init(), permanent: true);
      Get.putAsync<GeminiGameProvider>(() => GeminiGameProvider().init(), permanent: true);
    } catch (e) {
      debugPrint('❌ Error registering async services: $e');
    }

    // Register controllers
    try {
      debugPrint('📥 Registering controllers');
      Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
      Get.lazyPut<NavigationController>(() => NavigationController(), fenix: true);
      Get.lazyPut<GeminiAppController>(() => GeminiAppController(), fenix: true);
      Get.lazyPut<RandomPickerController>(() => RandomPickerController(), fenix: true);
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
      Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
      debugPrint('✅ All controllers registered successfully');
    } catch (e) {
      debugPrint('❌ Error registering controllers: $e');
    }

    debugPrint('✅ AppBinding.dependencies() completed');
  }
}
