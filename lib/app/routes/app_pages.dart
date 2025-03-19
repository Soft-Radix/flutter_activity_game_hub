import 'package:get/get.dart';

import '../modules/categories/categories_screen.dart';
import '../modules/game_details/game_details_screen.dart';
import '../modules/home/home_screen.dart';
import '../modules/leaderboard/leaderboard_screen.dart';
import '../modules/main_layout.dart';
import '../modules/onboarding/onboarding_screen.dart';
import '../modules/random_picker/random_picker_screen.dart';
import '../modules/saved_suggestions/saved_suggestions_screen.dart';
import '../modules/settings/settings_screen.dart';
import '../modules/splash/splash_screen.dart';
import '../modules/timer_scoreboard/timer_scoreboard_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashScreen(), transition: Transition.fadeIn),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: Routes.MAIN, page: () => const MainLayout(), transition: Transition.fadeIn),
    GetPage(name: Routes.HOME, page: () => const HomeScreen(), transition: Transition.fadeIn),
    GetPage(
      name: Routes.CATEGORIES,
      page: () => const CategoriesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.GAME_DETAILS,
      page: () => const GameDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.RANDOM_PICKER,
      page: () => const RandomPickerScreen(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: Routes.TIMER_SCOREBOARD,
      page: () => const TimerScoreboardScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.LEADERBOARD,
      page: () => const LeaderboardScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: Routes.SAVED_SUGGESTIONS, page: () => const SavedSuggestionsScreen()),
  ];
}
