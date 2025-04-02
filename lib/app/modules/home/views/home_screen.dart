import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../controllers/navigation_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../modules/categories/controllers/category_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/shadow_utils.dart';
import '../../../widgets/dark_mode_check.dart';
import '../controllers/home_controller.dart';
import '../widgets/activity_suggestion_card.dart';
import '../widgets/featured_game_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final categoryController = Get.find<CategoryController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
            extendBody: true,
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
              elevation: isDarkMode ? 0 : 2,
              shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? const Color(0xFF3051D3)
                              : const Color(0xFF4A6FFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sports_esports,
                      size: 18,
                      color: isDarkMode ? Colors.white : const Color(0xFF3051D3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Activity Game Hub',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                    ),
                  ),
                ],
              ),
              actions: [const SizedBox(width: 8)],
            ),
            body: Obx(
              () =>
                  controller.isLoading.value
                      ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                      : RefreshIndicator(
                        color: colorScheme.primary,
                        onRefresh: () async {
                          await controller.loadGames();
                        },
                        child: AnimationLimiter(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
                              gradient:
                                  isDarkMode
                                      ? null
                                      : LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white,
                                          const Color(0xFFF8F9FE),
                                          const Color(0xFFF0F3FA),
                                        ],
                                        stops: const [0.0, 0.4, 1.0],
                                      ),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.all(AppTheme.padding),
                              physics: const AlwaysScrollableScrollPhysics(),
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

                                  // Activity Suggestion Card
                                  const ActivitySuggestionCard(),
                                  const SizedBox(height: AppTheme.largePadding),

                                  // Category Grid Title
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppTheme.smallPadding,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              isDarkMode
                                                  ? Colors.white.withOpacity(0.1)
                                                  : Colors.black.withOpacity(0.05),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Game Categories',
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDarkMode
                                                ? AppTheme.textColorDarkMode
                                                : AppTheme.textColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.mediumPadding),

                                  // Category Grid
                                  _buildCategoryGrid(categoryController, navigationController),
                                  const SizedBox(height: AppTheme.largePadding),

                                  // Featured Game
                                  _buildFeaturedGameSection(context, controller, isDarkMode),

                                  // Extra padding at bottom
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
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
        elevation: isDarkMode ? AppTheme.mediumElevation : 0,
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
                      ? [const Color(0xFF4A6FFF).withOpacity(0.8), const Color(0xFF3A4CC1)]
                      : [const Color(0xFF4A6FFF), const Color(0xFF3051D3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow:
                isDarkMode
                    ? [
                      BoxShadow(
                        color: AppTheme.primaryColorDarkMode.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : ShadowUtils.getColoredShadow(
                      color: AppTheme.primaryColor,
                      opacity: 0.4,
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
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
              Text(
                'Activity Game Hub',
                style: textTheme.displaySmall?.copyWith(
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Find and play fun activities with your team!',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryGrid(
    CategoryController categoryController,
    NavigationController navigationController,
  ) {
    // Create a list of hardcoded categories
    final List<Map<String, dynamic>> categories = [
      {
        'id': 'icebreakers',
        'name': 'Ice Breakers',
        'description': 'Quick games to get the group comfortable',
        'color': Colors.blue,
        'icon': Icons.ac_unit_rounded,
      },
      {
        'id': 'team-building',
        'name': 'Team Building',
        'description': 'Activities to strengthen team bonds',
        'color': Colors.green,
        'icon': Icons.people_alt_rounded,
      },
      {
        'id': 'brain-games',
        'name': 'Brain Games',
        'description': 'Challenging puzzles and mind games',
        'color': Colors.purple,
        'icon': Icons.psychology_rounded,
      },
      {
        'id': 'quick-games',
        'name': 'Quick Games',
        'description': 'Fast and easy games for short breaks',
        'color': Colors.orange,
        'icon': Icons.speed_rounded,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.padding,
        mainAxisSpacing: AppTheme.padding,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categoryData = categories[index];

        return Card(
          
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            onTap: () {
              // Pass title to Categories screen
              Get.toNamed(AppRoutes.CATEGORIES, arguments: {'title': categoryData['name']});
            },
            child:  Container(
              
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [categoryData['color'].withOpacity(0.7), categoryData['color']],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(categoryData['icon'], color: Colors.white, size: 28),
                    ),

                    const SizedBox(height: 12),

                    // Name and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryData['name'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              categoryData['description'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedGameSection(
    BuildContext context,
    HomeController controller,
    bool isDarkMode,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured game title with info text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.smallPadding),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    width: 1.0,
                  ),
                ),
              ),
              child: Text(
                'Featured Game of the Day',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                ),
              ),
            ),
            Obx(
              () =>
                  controller.featuredServiceAvailable.value
                      ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Text removed - now displayed on the featured game card
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.mediumPadding),

        // Featured game card
        Obx(
          () =>
              controller.featuredGames.isNotEmpty
                  ? FeaturedGameCard(
                    game: controller.featuredGames.first,
                    onTap:
                        () => Get.toNamed(
                          AppRoutes.GAME_DETAILS,
                          arguments: controller.featuredGames.first,
                        ),
                  )
                  : Card(
                    color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                    ),
                    elevation: isDarkMode ? AppTheme.smallElevation : 0,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                        boxShadow:
                            isDarkMode
                                ? []
                                : ShadowUtils.getEnhancedContainerShadow(
                                  opacity: 0.08,
                                  blurRadius: 25,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 10),
                                ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode ? const Color(0xFF393F5F) : const Color(0xFFF0F3FA),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.games_outlined,
                                size: 30,
                                color:
                                    isDarkMode ? const Color(0xFF78A9FF) : const Color(0xFF3051D3),
                              ),
                            ),
                            const SizedBox(height: AppTheme.padding),
                            Text(
                              'No featured games available',
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
