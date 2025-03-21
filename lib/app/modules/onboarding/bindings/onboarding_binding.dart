import 'package:activity_game_hub_flutter/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:get/get.dart';



class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
