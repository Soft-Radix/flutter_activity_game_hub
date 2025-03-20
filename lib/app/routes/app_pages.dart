import 'package:activity_game_hub_flutter/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:get/get.dart';

import '../modules/categories/bindings/categories_binding.dart';
import '../modules/categories/views/categories_screen.dart';
import '../modules/game_details/bindings/game_details_binding.dart';
import '../modules/game_details/views/game_details_screen.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_screen.dart';
import '../modules/main_layout.dart';
import '../modules/onboarding/views/onboarding_screen.dart';
import '../modules/random_picker/bindings/random_picker_binding.dart';
import '../modules/random_picker/views/random_picker_screen.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_screen.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_screen.dart';
import '../modules/timer_scoreboard/bindings/timer_scoreboard_binding.dart';
import '../modules/timer_scoreboard/views/timer_scoreboard_screen.dart';

abstract class AppRoutes {
  static const INITIAL = '/';
  static const MAIN = '/main';
  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';

  static const SPLASH = '/splash';
  static const CATEGORIES = '/categories';
  static const GAME_DETAILS = '/game-details';
  static const RANDOM_PICKER = '/random-picker';
  static const TIMER_SCOREBOARD = '/timer-scoreboard';
  static const LEADERBOARD = '/leaderboard';
  static const SETTINGS = '/settings';
}

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: AppRoutes.MAIN, page: () => const MainLayout(), transition: Transition.fadeIn),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.CATEGORIES,
      page: () => const CategoriesScreen(),
      binding: CategoriesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.GAME_DETAILS,
      page: () => const GameDetailsScreen(),
      binding: GameDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.RANDOM_PICKER,
      page: () => const RandomPickerScreen(),
      binding: RandomPickerBinding(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: AppRoutes.TIMER_SCOREBOARD,
      page: () => const TimerScoreboardScreen(),
      binding: TimerScoreboardBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.LEADERBOARD,
      page: () => const LeaderboardScreen(),
      binding: LeaderboardBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
