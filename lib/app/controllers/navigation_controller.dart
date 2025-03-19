import 'package:get/get.dart';

import '../routes/app_pages.dart';

class NavigationController extends GetxController {
  // Current selected tab index
  final RxInt selectedIndex = 0.obs;

  // List of main routes
  final List<String> routes = [
    Routes.HOME,
    Routes.CATEGORIES,
    Routes.RANDOM_PICKER,
    Routes.LEADERBOARD,
    Routes.SETTINGS,
  ];

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
        return 'Categories';
      case 2:
        return 'Random Picker';
      case 3:
        return 'Leaderboard';
      case 4:
        return 'Settings';
      default:
        return 'Activity Game Hub';
    }
  }

  // Update index when navigating to a specific page externally
  void updateIndex(String route) {
    int index = routes.indexOf(route);
    if (index != -1) {
      selectedIndex.value = index;
    }
  }
}
