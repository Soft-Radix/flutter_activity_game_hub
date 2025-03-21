import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
class SplashController extends GetxController {
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulated initialization
    isLoading.value = false;
    Get.offAllNamed(AppRoutes.ONBOARDING);
  }
}
