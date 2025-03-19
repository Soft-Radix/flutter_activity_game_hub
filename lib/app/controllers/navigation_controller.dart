import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class NavigationController extends GetxController {
  // Current selected tab index
  final RxInt selectedIndex = 0.obs;

  // List of main routes
  final List<String> routes = [
    Routes.HOME,
    Routes.RANDOM_PICKER,
    Routes.LEADERBOARD,
    Routes.SETTINGS,
  ];

  @override
  void onInit() {
    super.onInit();
    // Ensure we always start at index 0 (Home)
    selectedIndex.value = 0;
  }

  // Change the selected tab
  void changePage(int index) {
    // Only update the index, don't navigate
    selectedIndex.value = index;
  }

  // Get page title based on index
  String getTitle(int index) {
    switch (index) {
      case 0:
        return 'Activity Game Hub';
      case 1:
        return 'Random Picker';
      case 2:
        return 'Leaderboard';
      case 3:
        return 'Settings';
      default:
        return 'Activity Game Hub';
    }
  }

  // Update index when navigating to a specific page externally
  // This method uses scheduleMicrotask to avoid updating during build phase
  void updateIndex(String route) {
    // Use scheduleMicrotask to defer the update until after the current build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int index = routes.indexOf(route);
      if (index != -1) {
        selectedIndex.value = index;
      }
    });
  }
}
