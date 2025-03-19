import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../data/models/category_model.dart';
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
  final RxBool _showFilters = false.obs;
  final RxBool _showSuggestions = false.obs;
  final RxList<String> _suggestions = <String>[].obs;
  final RxInt _currentCategoryIndex = 0.obs;

  // Dummy suggestion data - in a real app, this would come from your database
  final List<String> _dummySuggestions = [
    'Team building',
    'Ice breakers',
    'Quick games',
    'Large group activities',
    'Indoor games',
    'Outdoor activities',
    'No materials needed',
    'Games for kids',
    'Games for adults',
    'Party games',
    'Strategy games',
    'Communication games',
    'Problem-solving activities',
    'Brain teasers',
    'Trivia challenges',
    'Speed games',
    'Creativity boosters',
    'Collaboration exercises',
    'Memory games',
    'Word association games',
    'Role-playing activities',
    'Trust-building games',
    'Observation challenges',
    'Physical activity games',
    'Mindfulness and relaxation games',
    'Virtual team games',
    'Puzzle-solving activities',
    'Leadership challenges',
    'Guessing games',
    'Fun competitive games',
    'Hidden object games',
    'Drawing and sketching games',
    'Music and rhythm games',
    'Emoji-based games',
    'Debate and discussion games',
    'Improvisation exercises',
    'Coding-related mini-games (for tech teams)',
    'Scavenger hunts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _controller.categories.length, vsync: this);

    // Check if a specific category was selected
    if (_controller.selectedCategory.value != null) {
      final selectedCategory = _controller.selectedCategory.value!;
      final index = _controller.categories.indexWhere((c) => c.id == selectedCategory.id);
      if (index != -1) {
        _tabController.index = index;
        _currentCategoryIndex.value = index;
      }
      // Clear the selection after using it
      _controller.selectedCategory.value = null;
    }
    // For backward compatibility, also check arguments
    else if (Get.arguments != null) {
      final category = Get.arguments;
      // Check the type of the argument and handle accordingly
      if (category is String) {
        final index = _controller.categories.indexWhere((c) => c.name == category);
        if (index != -1) {
          _tabController.index = index;
          _currentCategoryIndex.value = index;
        }
      } else if (category is GameCategory) {
        final index = _controller.categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _tabController.index = index;
          _currentCategoryIndex.value = index;
        }
      }
    }

    // Update navigation controller index
    _navigationController.updateIndex(Routes.CATEGORIES);

    // Initialize filtered games list with the first category's games
    _updateFilteredGames();

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _showSuggestions.value = false;
      _suggestions.clear();
      return;
    }

    // Filter suggestions based on query
    _suggestions.value =
        _dummySuggestions.where((suggestion) => suggestion.toLowerCase().contains(query)).toList();

    // Show suggestions only if we have matches and text field has focus
    _showSuggestions.value = _suggestions.isNotEmpty;

    // Update current search query
    _currentSearchQuery.value = query;

    // Update filtered games
    _updateFilteredGames();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredGames() {
    final currentCategoryId = _controller.categories[_currentCategoryIndex.value].id;

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
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          // Hide suggestions when tapping outside
          _showSuggestions.value = false;
          FocusScope.of(context).unfocus();
        },
        child: Obx(() {
          final isDarkMode = _themeController.isDarkMode;
          final backgroundColor =
              isDarkMode ? Colors.grey.shade900 : colorScheme.primary.withOpacity(0.05);
          final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;

          return Column(
            children: [
              // App Bar and Search Section (Non-scrollable part)
              Material(
                elevation: 0,
                color: backgroundColor,
                child: Column(
                  children: [
                    // App Bar
                    AppBar(
                      title: Obx(() {
                        final currentCategory = _controller.categories[_currentCategoryIndex.value];
                        return Text(
                          currentCategory.name,
                          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        );
                      }),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Get.back(); // Simply navigate back
                        },
                      ),
                      actions: const [ThemeToggle(), SizedBox(width: 8)],
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: isDarkMode ? Colors.white : colorScheme.primary,
                    ),

                    // Search Bar Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search bar with rounded corners and filter button
                          Row(
                            children: [
                              // Search field
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus && _searchController.text.isNotEmpty) {
                                        _showSuggestions.value = _suggestions.isNotEmpty;
                                      } else {
                                        // Delay hiding suggestions to allow tapping
                                        Future.delayed(const Duration(milliseconds: 200), () {
                                          if (mounted) {
                                            _showSuggestions.value = false;
                                          }
                                        });
                                      }
                                    },
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        // The listener will handle this
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search games...',
                                        hintStyle: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade500,
                                          fontSize: 15,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          size: 20,
                                          color:
                                              isDarkMode
                                                  ? Colors.grey.shade400
                                                  : colorScheme.primary.withOpacity(0.7),
                                        ),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                                ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    size: 20,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade600,
                                                  ),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    _showSuggestions.value = false;
                                                  },
                                                )
                                                : null,
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Filter button
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: _showFilters.value ? colorScheme.primary : cardColor,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  child: InkWell(
                                    onTap: () {
                                      _showFilters.value = !_showFilters.value;
                                      // Hide suggestions when filter is tapped
                                      _showSuggestions.value = false;
                                      FocusScope.of(context).unfocus();
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.tune,
                                        color:
                                            _showFilters.value
                                                ? Colors.white
                                                : isDarkMode
                                                ? Colors.grey.shade400
                                                : colorScheme.primary.withOpacity(0.7),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Search suggestions (horizontal)
                          if (_showSuggestions.value) ...[
                            const SizedBox(height: 16),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                                    child: Text(
                                      'Suggestions',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDarkMode
                                                ? Colors.grey.shade300
                                                : colorScheme.primary.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 44,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _suggestions.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Material(
                                            color: cardColor,
                                            borderRadius: BorderRadius.circular(22),
                                            elevation: 1,
                                            shadowColor: Colors.black.withOpacity(0.1),
                                            child: InkWell(
                                              onTap: () {
                                                _searchController.text = _suggestions[index];
                                                _currentSearchQuery.value =
                                                    _suggestions[index].toLowerCase();
                                                _updateFilteredGames();
                                                _showSuggestions.value = false;
                                                FocusScope.of(context).unfocus();
                                              },
                                              borderRadius: BorderRadius.circular(22),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 10,
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.search,
                                                      size: 16,
                                                      color:
                                                          isDarkMode
                                                              ? Colors.grey.shade400
                                                              : colorScheme.primary.withOpacity(
                                                                0.7,
                                                              ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _suggestions[index],
                                                      style: TextStyle(
                                                        color:
                                                            isDarkMode
                                                                ? Colors.white
                                                                : Colors.black87,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Collapsible Filter Section
                          if (_showFilters.value) ...[
                            const SizedBox(height: 20),
                            // Filters Box
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with title and reset button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Filters',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // Reset filters
                                          _minPlayers.value = 1;
                                          _maxTime.value = 60;
                                          _updateFilteredGames();
                                        },
                                        icon: const Icon(Icons.refresh, size: 16),
                                        label: const Text('Reset'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: colorScheme.primary,
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Players filter
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Players:',
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Obx(
                                        () => Text(
                                          '${_minPlayers.value}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Wrap sliders in IgnorePointer to prevent scroll interference
                                  AbsorbPointer(
                                    absorbing: false, // We want the slider to be interactive
                                    child: Obx(
                                      () => Column(
                                        children: [
                                          SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              trackHeight: 6,
                                              activeTrackColor: colorScheme.primary,
                                              inactiveTrackColor: colorScheme.primary.withOpacity(
                                                0.2,
                                              ),
                                              thumbColor: colorScheme.primary,
                                              thumbShape: const RoundSliderThumbShape(
                                                enabledThumbRadius: 12,
                                              ),
                                              overlayColor: colorScheme.primary.withOpacity(0.2),
                                              overlayShape: const RoundSliderOverlayShape(
                                                overlayRadius: 24,
                                              ),
                                              valueIndicatorColor: colorScheme.primary,
                                              valueIndicatorShape:
                                                  const PaddleSliderValueIndicatorShape(),
                                              valueIndicatorTextStyle: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              showValueIndicator: ShowValueIndicator.always,
                                            ),
                                            child: Slider(
                                              value: _minPlayers.value.toDouble(),
                                              min: 1,
                                              max: 30,
                                              divisions: 29,
                                              label: "${_minPlayers.value} players",
                                              onChanged: (value) {
                                                _minPlayers.value = value.round();
                                                _updateFilteredGames();
                                              },
                                              semanticFormatterCallback: (double value) {
                                                return '${value.round()} players';
                                              },
                                            ),
                                          ),
                                          // Player count marks
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '1',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '15',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '30',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Time filter
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, color: Colors.teal, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Max Time:',
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Obx(
                                        () => Text(
                                          '${_maxTime.value} min',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Wrap sliders in IgnorePointer to prevent scroll interference
                                  AbsorbPointer(
                                    absorbing: false, // We want the slider to be interactive
                                    child: Obx(
                                      () => Column(
                                        children: [
                                          SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              trackHeight: 6,
                                              activeTrackColor: Colors.teal,
                                              inactiveTrackColor: Colors.teal.withOpacity(0.2),
                                              thumbColor: Colors.teal,
                                              thumbShape: const RoundSliderThumbShape(
                                                enabledThumbRadius: 12,
                                              ),
                                              overlayColor: Colors.teal.withOpacity(0.2),
                                              overlayShape: const RoundSliderOverlayShape(
                                                overlayRadius: 24,
                                              ),
                                              valueIndicatorColor: Colors.teal,
                                              valueIndicatorShape:
                                                  const PaddleSliderValueIndicatorShape(),
                                              valueIndicatorTextStyle: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              showValueIndicator: ShowValueIndicator.always,
                                            ),
                                            child: Slider(
                                              value: _maxTime.value.toDouble(),
                                              min: 5,
                                              max: 120,
                                              divisions: 23,
                                              label: "${_maxTime.value} min",
                                              onChanged: (value) {
                                                _maxTime.value = value.round();
                                                _updateFilteredGames();
                                              },
                                              semanticFormatterCallback: (double value) {
                                                return '${value.round()} minutes';
                                              },
                                            ),
                                          ),
                                          // Time marks
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '5 min',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '60 min',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '120 min',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey.shade400
                                                            : Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Add a divider for visual separation
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Game List (Scrollable part)
              Expanded(
                child: Obx(
                  () =>
                      _filteredGames.isEmpty
                          ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color:
                                          isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Icon(
                                      Icons.search_off_rounded,
                                      size: 40,
                                      color:
                                          isDarkMode
                                              ? Colors.grey.shade500
                                              : colorScheme.primary.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No Games Found',
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Try adjusting your search filters or try a different keyword',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color:
                                          isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Reset filters
                                      _minPlayers.value = 1;
                                      _maxTime.value = 60;
                                      _searchController.clear();
                                      _currentSearchQuery.value = '';
                                      _updateFilteredGames();
                                      _showFilters.value = false;
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Reset All Filters'),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : AnimationLimiter(
                            child: ListView.builder(
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
