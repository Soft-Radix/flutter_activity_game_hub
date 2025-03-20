import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../data/models/category_model.dart';
import '../../data/models/game_model.dart';
import '../../routes/app_pages.dart';
import '../../widgets/theme_toggle.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final AppController _controller = Get.find<AppController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final NavigationController _navigationController = Get.find<NavigationController>();
  final RxInt _currentCategoryIndex = 0.obs;
  final RxList<Game> _filteredGames = <Game>[].obs;
  final RxInt _minPlayers = 1.obs;
  final RxInt _maxTime = 60.obs;
  final TextEditingController _searchController = TextEditingController();
  final RxBool _isSearching = false.obs;
  final RxList<String> _searchSuggestions = <String>[].obs;
  final RxBool _showSuggestions = false.obs;

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

  // Filtered categories list - change from getter to property
  final RxList<GameCategory> _filteredCategories = <GameCategory>[].obs;

  @override
  void initState() {
    super.initState();

    // Initialize filtered categories
    _refreshFilteredCategories();

    // Check if a specific category was selected
    if (_controller.selectedCategory.value != null) {
      final selectedCategory = _controller.selectedCategory.value!;
      final index = _filteredCategories.indexWhere((c) => c.id == selectedCategory.id);
      if (index != -1) {
        _currentCategoryIndex.value = index;
      }
      // Clear the selection after using it
      _controller.selectedCategory.value = null;
    }

    // Update navigation controller index
    _navigationController.updateIndex(Routes.CATEGORIES);

    // Initialize filtered games
    _updateFilteredGames();

    // Add listener for search suggestions
    _searchController.addListener(_updateSearchSuggestions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Make sure categories are always properly filtered
    _refreshFilteredCategories();
  }

  void _refreshFilteredCategories() {
    // Ensure categories are properly filtered

    // If we have no categories after filtering or current index is out of bounds
    if (_filteredCategories.isEmpty || _currentCategoryIndex.value >= _filteredCategories.length) {
      _currentCategoryIndex.value = 0;
      _filteredGames.clear();
    } else {
      // Make sure games are updated based on the current category
      _updateFilteredGames();
    }
  }

  void _updateSearchSuggestions() {
    if (_searchController.text.isEmpty) {
      _searchSuggestions.clear();
      _showSuggestions.value = false;
      return;
    }

    final query = _searchController.text.toLowerCase();

    // Always show dummy suggestions and "all" option when user types
    List<String> suggestions = ['All results'];

    // Add dummy suggestions that match the query
    suggestions.addAll(
      _dummySuggestions.where((suggestion) => suggestion.toLowerCase().contains(query)),
    );

    // Use real game data as additional suggestions if any match
    final allGames = <Game>[];
    for (final category in _filteredCategories) {
      allGames.addAll(_controller.getGamesByCategory(category.id));
    }

    final matchedGames =
        allGames
            .where(
              (game) =>
                  game.name.toLowerCase().contains(query) ||
                  game.description.toLowerCase().contains(query),
            )
            .toList();

    // Add real matching game names to suggestions
    suggestions.addAll(matchedGames.map((game) => game.name).toSet());

    // Remove duplicates and limit
    suggestions = suggestions.toSet().toList();
    if (suggestions.length > 6) {
      suggestions = suggestions.sublist(0, 6);
    }

    _searchSuggestions.value = suggestions;
    _showSuggestions.value = true; // Always show suggestions when text is entered
  }

  void _updateFilteredGames() {
    if (_filteredCategories.isEmpty) {
      _filteredGames.clear();
      return;
    }

    final currentCategory = _filteredCategories[_currentCategoryIndex.value];
    final categoryGames = _controller.getGamesByCategory(currentCategory.id);

    // Apply filters
    _filteredGames.value =
        categoryGames.where((game) {
          // Filter by players
          final hasEnoughPlayers =
              game.minPlayers <= _minPlayers.value && game.maxPlayers >= _minPlayers.value;

          // Filter by time
          final withinTimeLimit = game.estimatedTimeMinutes <= _maxTime.value;

          // Filter by search query if any
          bool matchesSearch = true;
          if (_searchController.text.isNotEmpty) {
            matchesSearch =
                game.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                game.description.toLowerCase().contains(_searchController.text.toLowerCase());
          }

          return hasEnoughPlayers && withinTimeLimit && matchesSearch;
        }).toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchSuggestions);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Print the current categories for debugging
    print('Current filtered categories: ${_filteredCategories.map((c) => c.id).toList()}');

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (_filteredCategories.isEmpty) {
            return Text(
              'Game Categories',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            );
          }
          final currentCategory = _filteredCategories[_currentCategoryIndex.value];
          return Text(
            currentCategory.name,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          );
        }),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      body: Obx(() {
        final isDarkMode = _themeController.isDarkMode;
        final currentCategory =
            _filteredCategories.isEmpty ? null : _filteredCategories[_currentCategoryIndex.value];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and filter row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _updateFilteredGames();
                        },
                        onSubmitted: (value) {
                          _showSuggestions.value = false;
                        },
                        decoration: InputDecoration(
                          hintText: 'Search games...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _showSuggestions.value = false;
                                      _updateFilteredGames();
                                    },
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Filter button
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () => _showFiltersDialog(context),
                      icon: const Icon(Icons.tune),
                      tooltip: 'Filters',
                    ),
                  ),
                ],
              ),
            ),

            // Search suggestions
            Obx(
              () =>
                  _showSuggestions.value
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Suggestions" title
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                              child: Text(
                                'Suggestions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            // Suggestion chips in horizontal scroll
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _searchSuggestions.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final suggestion = _searchSuggestions[index];
                                  return InkWell(
                                    onTap: () {
                                      _searchController.text = suggestion;
                                      _showSuggestions.value = false;
                                      _updateFilteredGames();
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color:
                                              isDarkMode
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade300,
                                          width: 1,
                                        ),
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
                                                    : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            suggestion,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            // Category tabs - only show if we have filtered categories
            if (_filteredCategories.isNotEmpty) ...[
              // Debug output
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];

                    final isSelected = _currentCategoryIndex.value == index;
                    debugPrint('Building category tab: ${category.id} - ${category.name}');

                    return GestureDetector(
                      onTap: () {
                        _currentCategoryIndex.value = index;
                        _updateFilteredGames();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? category.color
                                  : isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],

            // Game grid or empty state
            Expanded(
              child: Obx(() {
                if (_filteredCategories.isEmpty) {
                  return _buildNoCategories(isDarkMode);
                }

                if (_filteredGames.isEmpty) {
                  return _buildEmptyState(isDarkMode, colorScheme, currentCategory!);
                }

                return AnimationLimiter(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = _filteredGames[index];

                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(child: _buildGameCard(game, context, isDarkMode)),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNoCategories(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No categories available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The selected categories have been removed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(GameCategory category, BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          _currentCategoryIndex.value = _controller.categories.indexWhere(
            (c) => c.id == category.id,
          );
          _updateFilteredGames();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: category.color.withOpacity(0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(_getCategoryIcon(category.id), color: category.color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                category.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(Game game, BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.GAME_DETAILS, arguments: game),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(image: AssetImage(game.imageUrl), fit: BoxFit.cover),
                ),
              ),
            ),

            // Game details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${game.minPlayers}-${game.maxPlayers}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${game.estimatedTimeMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, ColorScheme colorScheme, GameCategory category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No games found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or search for different games',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _minPlayers.value = 1;
                _maxTime.value = 60;
                _searchController.clear();
                _updateFilteredGames();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    // Create copies of current values for the dialog
    final players = _minPlayers.value.obs;
    final maxTime = _maxTime.value.obs;
    final isDarkMode = _themeController.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and reset button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      players.value = 1;
                      maxTime.value = 60;
                    },
                    icon: Icon(Icons.refresh, color: colorScheme.primary),
                    label: Text('Reset', style: TextStyle(color: colorScheme.primary)),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Players filter
              Row(
                children: [
                  Icon(Icons.people, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Players: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${players.value}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Players slider
              Obx(
                () => Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                        thumbColor: colorScheme.primary,
                        overlayColor: colorScheme.primary.withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        min: 1,
                        max: 30,
                        divisions: 29,
                        value: players.value.toDouble(),
                        onChanged: (value) => players.value = value.round(),
                      ),
                    ),

                    // Player labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '15',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '30',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Max time filter
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.teal),
                  const SizedBox(width: 12),
                  Text(
                    'Max Time: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${maxTime.value} min',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Time slider
              Obx(
                () => Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.teal,
                        inactiveTrackColor: Colors.teal.withOpacity(0.2),
                        thumbColor: Colors.teal,
                        overlayColor: Colors.teal.withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        min: 5,
                        max: 120,
                        divisions: 23,
                        value: maxTime.value.toDouble(),
                        onChanged: (value) => maxTime.value = value.round(),
                      ),
                    ),

                    // Time labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '5 min',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '60 min',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '120 min',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _minPlayers.value = players.value;
                      _maxTime.value = maxTime.value;
                      _updateFilteredGames();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'icebreakers':
        return Icons.ac_unit_rounded;
      case 'team-building':
        return Icons.people_alt_rounded;
      case 'brain-games':
        return Icons.psychology_rounded;
      case 'quick-games':
        return Icons.speed_rounded;
      default:
        return Icons.extension_rounded;
    }
  }
}
