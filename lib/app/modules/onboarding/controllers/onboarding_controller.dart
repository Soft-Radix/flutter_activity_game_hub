import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;

  // Current page index
  final RxInt currentPage = 0.obs;

  // List of onboarding pages
  final List<Map<String, String>> onboardingPages = [
    {
      'title': 'Welcome to Activity Hub',
      'description': 'Discover fun activities for team building and collaboration.',
      'image': 'assets/images/onboarding_1.png',
    },
    {
      'title': 'Find Perfect Activities',
      'description': 'Browse through various categories and find activities that suit your needs.',
      'image': 'assets/images/onboarding_2.png',
    },
    {
      'title': 'Track Progress',
      'description': 'Keep track of your team\'s performance and progress.',
      'image': 'assets/images/onboarding_3.png',
    },
  ];

  // Navigate to next page
  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      currentPage.value++;
    } else {
      // Navigate to main layout
      Get.offAllNamed(AppRoutes.MAIN);
    }
  }

  // Navigate to previous page
  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  // Skip onboarding
  void skipOnboarding() {
    Get.offAllNamed(AppRoutes.MAIN);
  }
}
