import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../routes/app_pages.dart';
import '../../themes/app_theme.dart';
import '../../widgets/theme_toggle.dart';
import 'widgets/category_card.dart';
import 'widgets/chatgpt_suggestion_card.dart';
import 'widgets/featured_game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the AppController and ThemeController
    final controller = Get.find<AppController>();
    final themeController = Get.find<ThemeController>();
    final navigationController = Get.find<NavigationController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Activity Game Hub',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [const ThemeToggle(), const SizedBox(width: 8)],
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : RefreshIndicator(
                  color: colorScheme.primary,
                  onRefresh: () async {
                    await controller.loadGames();
                    await controller.getGameSuggestion();
                    await controller.getGameOfTheDay();
                  },
                  child: AnimationLimiter(
                    child: ListView(
                      padding: const EdgeInsets.all(AppTheme.padding),
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder:
                            (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(child: widget),
                            ),
                        children: [
                          // Welcome message
                          _buildWelcomeMessage(context),
                          const SizedBox(height: AppTheme.padding),

                          // ChatGPT Suggestion Box
                          ChatGptSuggestionCard(
                            onRefresh: () => controller.getGameSuggestion(),
                            onSearch: () {
                              // Show dialog to input search parameters
                              _showSearchDialog(context, controller);
                            },
                          ),

                          // View saved suggestions button
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => Get.toNamed(Routes.SAVED_SUGGESTIONS),
                              icon: const Icon(Icons.collections_bookmark),
                              label: const Text('View All Suggestions'),
                              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                            ),
                          ),
                          const SizedBox(height: AppTheme.largePadding),

                          // Category Grid Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Game Categories',
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // Navigate to Categories screen directly
                                  Get.toNamed(Routes.CATEGORIES);
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('See All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.smallPadding),

                          // Category Grid
                          _buildCategoryGrid(controller, navigationController),
                          const SizedBox(height: AppTheme.largePadding),

                          // Featured Game
                          Text(
                            'Featured Game of the Day',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppTheme.smallPadding),

                          // Featured Game Card
                          controller.featuredGames.isNotEmpty
                              ? FeaturedGameCard(
                                game: controller.featuredGames.first,
                                onTap:
                                    () => Get.toNamed(
                                      Routes.GAME_DETAILS,
                                      arguments: controller.featuredGames.first,
                                    ),
                              )
                              : Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                                ),
                                elevation: AppTheme.smallElevation,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.padding),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color:
                                            themeController.isDarkMode
                                                ? AppTheme.lightTextColorDarkMode
                                                : AppTheme.lightTextColor,
                                      ),
                                      const SizedBox(height: AppTheme.smallPadding),
                                      Text(
                                        'No featured games available',
                                        style: textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SizedBox(height: AppTheme.largePadding),

                          // Extra padding at bottom to account for the bottom navigation bar
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;

      return Card(
        elevation: AppTheme.mediumElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [AppTheme.primaryColorDarkMode, const Color(0xFF3A4CC1)]
                      : [AppTheme.primaryColor, const Color(0xFF3A4CC1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        ? AppTheme.primaryColorDarkMode.withOpacity(0.3)
                        : AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Activity Game Hub',
                    textStyle: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.padding,
                  vertical: AppTheme.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Text(
                  'Find and play fun activities with your team!',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryGrid(AppController controller, NavigationController navigationController) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return CategoryCard(
          category: category,
          onTap: () {
            // Navigate directly to Categories screen
            Get.find<AppController>().selectedCategory.value = category;
            Get.toNamed(Routes.CATEGORIES);
          },
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context, AppController controller) {
    int? players;
    int? timeMinutes;
    String? category;
    String? preferences;

    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search, color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Text('Find a Game', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Number of Players',
                      hintText: 'E.g., 5',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        players = int.tryParse(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Available Time (minutes)',
                      hintText: 'E.g., 20',
                      prefixIcon: const Icon(Icons.timer_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        timeMinutes = int.tryParse(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Preferred Category',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                    ),
                    items:
                        controller.categories
                            .map((cat) => DropdownMenuItem(value: cat.name, child: Text(cat.name)))
                            .toList(),
                    onChanged: (value) {
                      category = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Additional Preferences',
                      hintText: 'E.g., low energy, fun, no materials',
                      prefixIcon: const Icon(Icons.list_alt_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                    ),
                    onChanged: (value) {
                      preferences = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.getGameSuggestion(
                    numberOfPlayers: players,
                    availableTimeMinutes: timeMinutes,
                    preferredCategory: category,
                    additionalPreferences: preferences,
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: AppTheme.smallElevation,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
    );
  }
}
