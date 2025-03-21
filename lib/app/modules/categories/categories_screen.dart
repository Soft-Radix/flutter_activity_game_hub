import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/gemini_app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../data/models/category_model.dart';
import '../../data/models/game_model.dart';
import '../../data/services/gemini_api_service.dart';
import '../../modules/categories/controllers/category_controller.dart';
import '../../routes/app_pages.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final GeminiAppController _geminiController = Get.find<GeminiAppController>();
  final CategoryController _categoryController = Get.find<CategoryController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final NavigationController _navigationController = Get.find<NavigationController>();
  final RxInt _currentCategoryIndex = 0.obs;
  final RxList<Game> _filteredGames = <Game>[].obs;
  final RxInt _minPlayers = 15.obs;
  final RxInt _maxTime = 60.obs;
  final TextEditingController _searchController = TextEditingController();
  final RxBool _isSearching = false.obs;
  final RxList<String> _searchSuggestions = <String>[].obs;
  final RxBool _showSuggestions = false.obs;
  final RxBool _isGeminiMode = false.obs;
  final RxBool _isApiLoading = false.obs;

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

  // List of category IDs to exclude from display
  final List<String> _excludedCategories = [
    'brain-games',
    'quick-games',
    'icebreakers',
    'team-building',
  ];

  // Filtered categories list - change from getter to property
  final RxList<GameCategory> _filteredCategories = <GameCategory>[].obs;

  @override
  void initState() {
    super.initState();

    // Check if we should use Gemini mode
    if (Get.arguments != null && Get.arguments['useGemini'] == true) {
      _isGeminiMode.value = true;

      // If a specific category was passed from home
      if (Get.arguments['category'] != null) {
        final selectedCategory = Get.arguments['category'] as GameCategory;
        _searchController.text = selectedCategory.name;
      }
    }

    // Initialize filtered categories using CategoryController
    _refreshFilteredCategories();

    // Update navigation controller index
    _navigationController.updateIndex(AppRoutes.CATEGORIES);

    // Initialize filtered games

    // Add listener for search suggestions
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Make sure categories are always properly filtered
    _refreshFilteredCategories();
  }

  void _refreshFilteredCategories() {
    // If we have no categories after filtering or current index is out of bounds
    if (_filteredCategories.isEmpty || _currentCategoryIndex.value >= _filteredCategories.length) {
      _currentCategoryIndex.value = 0;
      _filteredGames.clear();
    } else {
      // Make sure games are updated based on the current category
    }
  }

  // New method to search games using Gemini API
  Future<void> _searchGamesWithGemini() async {
    debugPrint('===== SEARCHING WITH GEMINI =====');
    debugPrint('Search method called with query: "${_searchController.text}"');
    debugPrint(
      'Current filter values - Min Players: ${_minPlayers.value}, Max Time: ${_maxTime.value}',
    );

    if (_searchController.text.isEmpty) {
      Get.snackbar(
        'Search Required',
        'Please enter a search term',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isApiLoading.value = true;
    _showSuggestions.value = false;
    _filteredGames.clear(); // Clear previous results

    try {
      // Get the search query
      String searchQuery = _searchController.text;
      debugPrint('Starting search for: "$searchQuery"');

      // Create a direct instance of the GeminiApiService to access and print API details
      final geminiApiService = GeminiApiService();

      // Print the API URL
      debugPrint('===== GEMINI API URL =====');
      debugPrint(geminiApiService.apiUrl);
      debugPrint('===== END API URL =====');

      // Try direct API call first with filter parameters
      debugPrint('===== MAKING DIRECT API CALL WITH FILTERS =====');
      debugPrint(
        'Filters being applied - Min Players: ${_minPlayers.value}, Max Time: ${_maxTime.value}',
      );

      // Ensure minPlayers is at least 1 to avoid API issues
      final effectiveMinPlayers = _minPlayers.value > 0 ? _minPlayers.value : 15;

      final directApiGames = await geminiApiService.getGames(
        category: searchQuery,
        minPlayers: effectiveMinPlayers, // Pass the filter value directly
        maxPlayers: effectiveMinPlayers, // Use min players for max to ensure compatibility
        maxTimeMinutes: _maxTime.value, // Pass the filter value directly
      );
      debugPrint('Direct API call returned ${directApiGames.length} games');
      debugPrint(
        'Games returned with min players: ${directApiGames.map((g) => "${g.name} (min: ${g.minPlayers}, max: ${g.maxPlayers}, time: ${g.estimatedTimeMinutes})").join(", ")}',
      );

      // Now call the Gemini API with the search query through the controller with filters
      // First set the filters in the controller
      debugPrint('===== SETTING CONTROLLER FILTERS =====');
      // Create a temporary category to set in the controller
      final tempCategory = GameCategory(
        id: searchQuery.toLowerCase().replaceAll(' ', '-'),
        name: searchQuery,
        description: searchQuery,
        color: Colors.blue,
        iconPath: 'assets/icons/game.svg',
      );

      // Set the filters in the controller
      _geminiController.selectedCategory.value = tempCategory;
      _geminiController.selectedPlayerCount.value = effectiveMinPlayers;
      _geminiController.selectedMaxTime.value = _maxTime.value;

      // Now make the call with the controller
      debugPrint('===== MAKING CONTROLLER API CALL WITH FILTERS =====');
      debugPrint(
        'Controller filter values - Category: ${_geminiController.selectedCategory.value?.name}, Players: ${_geminiController.selectedPlayerCount.value}, Max Time: ${_geminiController.selectedMaxTime.value}',
      );

      await _geminiController.getGamesWithFilters();
      debugPrint('Controller API call completed');
      debugPrint('Controller returned ${_geminiController.games.length} games');
      debugPrint(
        'Games returned from controller: ${_geminiController.games.map((g) => "${g.name} (min: ${g.minPlayers}, max: ${g.maxPlayers}, time: ${g.estimatedTimeMinutes})").join(", ")}',
      );

      // Print API details to console
      debugPrint('===== SEARCH QUERY =====');
      debugPrint('Query: $searchQuery');
      debugPrint('Filters: Min Players: $effectiveMinPlayers, Max Time: ${_maxTime.value}');
      debugPrint('===== END SEARCH QUERY =====');

      // Display a snackbar to show that API details are available
      Get.snackbar(
        'API Details Available',
        'API URL, prompt, and response printed to console. Tap the code button in the app bar to view details.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // For diagnostic purposes
      debugPrint('Controller has ${_geminiController.games.length} games after API call');

      // Now we don't need to filter the results locally as they were already filtered by the API
      // Just use the results directly
      _filteredGames.value =
          _geminiController.games.isEmpty ? directApiGames : _geminiController.games;

      // Double-check that games meet our filter criteria
      debugPrint('===== VERIFYING FILTERED GAMES =====');
      final matchFilter =
          _filteredGames.where((game) {
            final hasEnoughPlayers =
                game.minPlayers <= effectiveMinPlayers && game.maxPlayers >= effectiveMinPlayers;
            final withinTimeLimit = game.estimatedTimeMinutes <= _maxTime.value;
            final meetsCriteria = hasEnoughPlayers && withinTimeLimit;

            if (!meetsCriteria) {
              debugPrint(
                '⚠️ Game does not meet filter criteria: ${game.name} (min: ${game.minPlayers}, max: ${game.maxPlayers}, time: ${game.estimatedTimeMinutes})',
              );
            }

            return meetsCriteria;
          }).toList();

      debugPrint(
        '${matchFilter.length} out of ${_filteredGames.length} games meet filter criteria',
      );

      // If some games don't meet criteria, replace with only those that do
      if (matchFilter.length < _filteredGames.length && matchFilter.isNotEmpty) {
        debugPrint(
          '⚠️ Some games do not meet filter criteria! Filtering locally to ensure accuracy.',
        );
        _filteredGames.value = matchFilter;
      }

      // Display results count for diagnosis
      debugPrint('Final filtered games count: ${_filteredGames.length}');

      if (_filteredGames.isEmpty && directApiGames.isNotEmpty) {
        // If direct API call has games but controller failed
        debugPrint('Using direct API results as fallback');

        // Filter direct API games to ensure they meet criteria
        final filteredDirectGames =
            directApiGames.where((game) {
              final hasEnoughPlayers =
                  game.minPlayers <= effectiveMinPlayers && game.maxPlayers >= effectiveMinPlayers;
              final withinTimeLimit = game.estimatedTimeMinutes <= _maxTime.value;
              return hasEnoughPlayers && withinTimeLimit;
            }).toList();

        _filteredGames.value = filteredDirectGames;

        Get.snackbar(
          'Controller Issue',
          'Using direct API results instead. This indicates a potential controller issue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (_filteredGames.isEmpty) {
        // If no games at all, show a different message
        Get.snackbar(
          'No Results',
          'No games found for "${_searchController.text}" with your filter settings. Try different search terms or adjust your filters.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Search Complete',
          'Found ${_filteredGames.length} games matching "${_searchController.text}" for $effectiveMinPlayers players and up to ${_maxTime.value} minutes',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('===== ERROR DURING SEARCH =====');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error details: $e');

      Get.snackbar(
        'Error',
        'Failed to search games: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Log the error for debugging
      debugPrint('Error searching games: $e');
    } finally {
      _isApiLoading.value = false;
      debugPrint('===== SEARCH COMPLETED =====');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (_isGeminiMode.value) {
            return Text(
              'Gemini Search',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            );
          }

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
        actions: [
          // Display API Response button only in Gemini Mode
          Obx(
            () =>
                _isGeminiMode.value
                    ? Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          // Create an instance of GeminiApiService
                          final geminiApiService = GeminiApiService();
                          // Call the printLastApiResponse method
                          geminiApiService.printLastApiResponse();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.code, size: 20, color: Colors.blue),
                              const SizedBox(width: 4),
                              const Text(
                                'API',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive layout based on available width
                  final bool isNarrowLayout = constraints.maxWidth < 360;

                  return Row(
                    children: [
                      // Search field with clear button
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              // Only update for non-Gemini mode
                              if (!_isGeminiMode.value) {}
                            },
                            onSubmitted: (value) {
                              _showSuggestions.value = false;
                              if (_isGeminiMode.value && value.isNotEmpty) {
                                _searchGamesWithGemini();
                              } else if (!_isGeminiMode.value) {}
                            },
                            decoration: InputDecoration(
                              hintText:
                                  isNarrowLayout
                                      ? 'Search...'
                                      : (_isGeminiMode.value
                                          ? 'Search with Gemini...'
                                          : 'Search games...'),
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          _showSuggestions.value = false;
                                          if (!_isGeminiMode.value) {}
                                        },
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),

                      // Search button (only in Gemini mode)
                      if (_isGeminiMode.value && !isNarrowLayout) ...[
                        const SizedBox(width: 8),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_searchController.text.isNotEmpty) {
                                  _searchGamesWithGemini();
                                } else {
                                  Get.snackbar(
                                    'Search Required',
                                    'Please enter a search term',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(25),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.search, color: Colors.white),
                                    if (!isNarrowLayout) ...[
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Search',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(width: 8),

                      // Always visible search button
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              if (_isGeminiMode.value) {
                                _searchGamesWithGemini();
                              } else {
                                _showSuggestions.value = false;
                              }
                            } else {
                              Get.snackbar(
                                'Search Required',
                                'Please enter a search term',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          icon: Icon(Icons.search, color: colorScheme.primary),
                          tooltip: 'Search',
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Filter button
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: () => _showFiltersDialog(context),
                          icon: const Icon(Icons.tune),
                          tooltip: 'Filters',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  );
                },
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
                                      if (_isGeminiMode.value) {
                                        _searchGamesWithGemini();
                                      } else {}
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

            // Category tabs - only show if we have filtered categories and not in Gemini mode
            if (_filteredCategories.isNotEmpty && !_isGeminiMode.value) ...[
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    final isSelected = _currentCategoryIndex.value == index;

                    return GestureDetector(
                      onTap: () {
                        _currentCategoryIndex.value = index;
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

            // Show games list or empty state
            Expanded(
              child: Obx(() {
                if (_isApiLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Theme.of(context).primaryColor),
                        const SizedBox(height: 16),
                        Text(
                          'Searching with Gemini...',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This may take a few seconds',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white54 : Colors.black38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (_filteredCategories.isEmpty && !_isGeminiMode.value) {
                  return _buildNoCategories(isDarkMode);
                } else if (_filteredGames.isEmpty &&
                    _searchController.text.isNotEmpty &&
                    _isGeminiMode.value) {
                  // No results after search
                  return _buildEmptyState(isDarkMode);
                } else if (_filteredGames.isEmpty && _isGeminiMode.value) {
                  // Empty starting state for Gemini mode
                  return _buildGeminiSearchPrompt(isDarkMode, colorScheme);
                } else if (_filteredGames.isEmpty) {
                  // Regular empty state
                  return _buildEmptyState(isDarkMode);
                } else {
                  // Results to display
                  return _isGeminiMode.value
                      ? ListView.builder(
                        itemCount: _filteredGames.length,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        itemBuilder:
                            (context, index) =>
                                _buildGameListItem(_filteredGames[index], context, isDarkMode),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredGames.length,
                        itemBuilder:
                            (context, index) =>
                                _buildGameCard(_filteredGames[index], context, isDarkMode),
                      );
                }
              }),
            ),
          ],
        );
      }),
    );
  }

  // New widget for Gemini search prompt
  Widget _buildGeminiSearchPrompt(bool isDarkMode, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                child: Icon(Icons.smart_toy_outlined, size: 35, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 16),
              Text(
                "Search with Gemini",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Enter a search term above to find games using the Gemini API.",
                style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white54 : Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Use a responsive container width
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 320),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First step
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text("1.", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.search, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Enter your search",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Second step
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("2.", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search, color: Colors.white, size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    "SEARCH",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Click search",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search button options
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text("Main search button", style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text("Search icon", style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // Focus on the search field
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Start Typing to Search"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New method to build list item for Gemini mode
  Widget _buildGameListItem(Game game, BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.GAME_DETAILS, arguments: game);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 100, height: 100, child: _buildGameImage(game.imageUrl)),
              ),

              const SizedBox(width: 12),

              // Game details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      game.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      game.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Game metadata row
                    Row(
                      children: [
                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            game.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Players count
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${game.minPlayers}-${game.maxPlayers}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // Time duration
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${game.estimatedTimeMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoCategories(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(height: 24),
            Text(
              "No categories available",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "The selected categories have been removed",
              style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white54 : Colors.black54),
              textAlign: TextAlign.center,
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
        onTap: () {},
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
        onTap: () => Get.toNamed(AppRoutes.GAME_DETAILS, arguments: game),
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
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildGameImage(game.imageUrl),
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

  // Widget to display when no games match the filters
  Widget _buildEmptyState(bool isDarkMode) {
    final bool isSearchResults = _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearchResults ? Icons.search_off : Icons.category_outlined,
              size: 64,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(height: 24),
            Text(
              isSearchResults ? "No results" : "No categories available",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isSearchResults
                  ? "No games found for \"${_searchController.text}\". Try a different search term."
                  : "The selected categories have been removed",
              style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white54 : Colors.black54),
              textAlign: TextAlign.center,
            ),
            if (_isGeminiMode.value && !isSearchResults) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Enter a search term and click a Search button",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    "You can use either the main Search button or the Search icon",
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (isSearchResults && _isGeminiMode.value)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _searchGamesWithGemini,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      _filteredGames.clear();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Clear Search"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
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
                      players.value = 15;
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
                        min: 15,
                        max: 30,
                        divisions: 15,
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
                            '15',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '20',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '25',
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
                      Get.back();

                      // If in Gemini mode and we have a search query, re-execute the search with new filters
                      if (_isGeminiMode.value && _searchController.text.isNotEmpty) {
                        _searchGamesWithGemini();
                      }
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

  // Method to reset all filters
  void _resetFilters() {
    _minPlayers.value = 15;
    _maxTime.value = 60;
    _searchController.clear();
  }

  // Helper method to build game image from URL or asset
  Widget _buildGameImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Remote image from URL
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
      );
    } else if (imageUrl.startsWith('assets/')) {
      // Local asset image
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      // Fallback to placeholder image
      return Image.asset(
        'assets/images/placeholder.svg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    }
  }
}
