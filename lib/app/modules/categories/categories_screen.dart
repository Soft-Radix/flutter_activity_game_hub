import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../data/models/game_model.dart';
import '../../routes/app_pages.dart';
import '../../themes/app_theme.dart';
import '../../widgets/theme_toggle.dart';
import 'widgets/game_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppController _controller = Get.find<AppController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final NavigationController _navigationController = Get.find<NavigationController>();
  final TextEditingController _searchController = TextEditingController();
  final RxList<Game> _filteredGames = <Game>[].obs;
  final RxString _currentSearchQuery = ''.obs;
  final RxInt _minPlayers = 1.obs;
  final RxInt _maxTime = 60.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _controller.categories.length, vsync: this);

    // Check if a specific category was passed as an argument
    if (Get.arguments != null) {
      final category = Get.arguments as String;
      final index = _controller.categories.indexWhere((c) => c.name == category);
      if (index != -1) {
        _tabController.index = index;
      }
    }

    // Initialize filtered games list with the first category's games
    _updateFilteredGames();

    // Add listener to update filtered games when tab changes
    _tabController.addListener(() {
      _updateFilteredGames();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredGames() {
    final currentCategoryId = _controller.categories[_tabController.index].id;

    // Filter by category
    List<Game> games = _controller.getGamesByCategory(currentCategoryId);

    // Filter by search query if it exists
    if (_currentSearchQuery.value.isNotEmpty) {
      final query = _currentSearchQuery.value.toLowerCase();
      games =
          games
              .where(
                (game) =>
                    game.name.toLowerCase().contains(query) ||
                    game.description.toLowerCase().contains(query),
              )
              .toList();
    }

    // Filter by player count
    games =
        games
            .where(
              (game) =>
                  game.minPlayers <= _minPlayers.value && game.maxPlayers >= _minPlayers.value,
            )
            .toList();

    // Filter by time
    games = games.where((game) => game.estimatedTimeMinutes <= _maxTime.value).toList();

    _filteredGames.value = games;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Game Categories', style: textTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _navigationController.changePage(0), // Navigate back to home
        ),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor:
              _themeController.isDarkMode
                  ? AppTheme.lightTextColorDarkMode
                  : AppTheme.lightTextColor,
          tabs: _controller.categories.map((category) => Tab(text: category.name)).toList(),
          onTap: (index) {
            _updateFilteredGames();
          },
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Obx(() {
            final isDarkMode = _themeController.isDarkMode;
            return Container(
              padding: const EdgeInsets.all(AppTheme.padding),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.surfaceColorDarkMode : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search games...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? AppTheme.cardColorDarkMode : Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Players:',
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: colorScheme.primary,
                                  inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                                  thumbColor: colorScheme.primary,
                                  overlayColor: colorScheme.primary.withOpacity(0.1),
                                  valueIndicatorColor: colorScheme.primary,
                                  valueIndicatorTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Slider(
                                  value: _minPlayers.value.toDouble(),
                                  min: 1,
                                  max: 30,
                                  divisions: 29,
                                  label: _minPlayers.value.toString(),
                                  onChanged: (value) {
                                    _minPlayers.value = value.round();
                                    _updateFilteredGames();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Max Time (min):',
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: colorScheme.secondary,
                                  inactiveTrackColor: colorScheme.secondary.withOpacity(0.2),
                                  thumbColor: colorScheme.secondary,
                                  overlayColor: colorScheme.secondary.withOpacity(0.1),
                                  valueIndicatorColor: colorScheme.secondary,
                                  valueIndicatorTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Slider(
                                  value: _maxTime.value.toDouble(),
                                  min: 5,
                                  max: 120,
                                  divisions: 23,
                                  label: _maxTime.value.toString(),
                                  onChanged: (value) {
                                    _maxTime.value = value.round();
                                    _updateFilteredGames();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Games List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  _controller.categories.map((category) {
                    return Obx(
                      () =>
                          _filteredGames.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color:
                                          _themeController.isDarkMode
                                              ? AppTheme.lightTextColorDarkMode
                                              : AppTheme.lightTextColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text('No games found', style: textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    Text('Try adjusting your filters', style: textTheme.bodyMedium),
                                  ],
                                ),
                              )
                              : AnimationLimiter(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(AppTheme.padding),
                                  itemCount: _filteredGames.length,
                                  itemBuilder: (context, index) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: GameCard(
                                            game: _filteredGames[index],
                                            onTap:
                                                () => Get.toNamed(
                                                  Routes.GAME_DETAILS,
                                                  arguments: _filteredGames[index],
                                                ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
