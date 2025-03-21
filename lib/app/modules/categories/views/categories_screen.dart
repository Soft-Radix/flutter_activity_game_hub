import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/navigation_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../data/models/game_model.dart';
import '../../../modules/categories/controllers/category_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final NavigationController _navigationController = Get.find<NavigationController>();
  final TextEditingController _searchController = TextEditingController();
  final RxList<Game> _filteredGames = <Game>[].obs;
  final RxString _screenTitle = "Games".obs;
  final RxInt _minPlayers = 1.obs;
  final RxInt _maxTime = 60.obs;
  final RxList<String> _searchSuggestions = <String>[].obs;
  final RxBool _showSuggestions = false.obs;

  // Sample suggestions
  final List<String> _dummySuggestions = [
    'Team building',
    'Ice breakers',
    'Quick games',
    'Indoor games',
    'Outdoor activities',
    'No materials needed',
    'Party games',
    'Strategy games',
    'Brain teasers',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize flag to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get title from arguments if passed
      if (Get.arguments != null && Get.arguments['title'] != null) {
        _screenTitle.value = Get.arguments['title'];
        // Force update controller to ensure UI reflects changes
        _categoryController.refreshUI();
      }

      // Update navigation controller index
      _navigationController.updateIndex(AppRoutes.CATEGORIES);

      // Initialize filtered games
      _updateFilteredGames();
    });

    // Add listener for search suggestions
    _searchController.addListener(_updateSearchSuggestions);

    // Setup listener for screen title changes to update UI
    ever(_screenTitle, (_) => _categoryController.refreshUI());
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchSuggestions);
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchSuggestions() {
    if (_searchController.text.isEmpty) {
      _searchSuggestions.clear();
      _showSuggestions.value = false;
      return;
    }

    final query = _searchController.text.toLowerCase();
    List<String> suggestions = ['All games'];

    // Add suggestions that match the query
    suggestions.addAll(
      _dummySuggestions.where((suggestion) => suggestion.toLowerCase().contains(query)),
    );

    // Get game names that match the query
    final allGames = _categoryController.getGamesForDisplay();
    final matchedGames =
        allGames.where((game) {
          return game.name.toLowerCase().contains(query) ||
              game.description.toLowerCase().contains(query);
        }).toList();

    // Add game names to suggestions
    suggestions.addAll(matchedGames.map((game) => game.name).toSet());

    // Remove duplicates and limit
    suggestions = suggestions.toSet().toList();
    if (suggestions.length > 6) {
      suggestions = suggestions.sublist(0, 6);
    }

    _searchSuggestions.value = suggestions;
    _showSuggestions.value = true;
  }

  void _updateFilteredGames() {
    final searchText = _searchController.text.toLowerCase();
    final allGames = _categoryController.getGamesForDisplay();

    _filteredGames.value =
        allGames.where((game) {
          // Search filter
          final matchesSearch =
              searchText.isEmpty ||
              game.name.toLowerCase().contains(searchText) ||
              game.description.toLowerCase().contains(searchText);

          // Player filter
          final hasEnoughPlayers =
              game.minPlayers <= _minPlayers.value && game.maxPlayers >= _minPlayers.value;

          // Time filter
          final withinTimeLimit = game.estimatedTimeMinutes <= _maxTime.value;

          return matchesSearch && hasEnoughPlayers && withinTimeLimit;
        }).toList();

    // Force update to ensure UI reflects changes even during hot restart
    _categoryController.update(['filteredGames']);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeController.isDarkMode;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1C2A) : const Color(0xFFF0F4FF);
    final textColor = isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor;
    final subtitleColor = isDarkMode ? AppTheme.lightTextColorDarkMode : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, size: 22, color: textColor),
                      padding: EdgeInsets.zero,
                      onPressed: () => Get.back(),
                    ),
                  ),

                  // Title with icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        // Get title icon
                        IconData titleIcon = Icons.sports_esports;
                        Color iconColor =
                            isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

                        // Check category and assign appropriate icon
                        final title = _screenTitle.value.toLowerCase();
                        if (title.contains('ice breaker')) {
                          titleIcon = Icons.ac_unit_rounded;
                          iconColor = isDarkMode ? Colors.lightBlue : Colors.blue;
                        } else if (title.contains('team building')) {
                          titleIcon = Icons.people_alt_rounded;
                          iconColor = isDarkMode ? Colors.lightGreen : Colors.green;
                        } else if (title.contains('brain game')) {
                          titleIcon = Icons.psychology_rounded;
                          iconColor = isDarkMode ? Colors.purpleAccent : Colors.purple;
                        } else if (title.contains('quick game')) {
                          titleIcon = Icons.speed_rounded;
                          iconColor = isDarkMode ? Colors.amber : Colors.orange;
                        }

                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(titleIcon, size: 18, color: iconColor),
                        );
                      }),
                      const SizedBox(width: 8),
                      Obx(
                        () => Text(
                          _screenTitle.value,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Empty container for balance (replacing sun icon)
                  SizedBox(width: 48, height: 48),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
                            blurRadius: isDarkMode ? 8 : 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left search icon in blue circle
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? const Color(0xFF2D3250)
                                      : primaryColor.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(Icons.search, color: primaryColor, size: 22),
                          ),
                          // Text Field
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: const InputDecorationTheme(filled: false),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(fontSize: 15, color: textColor, height: 1.1),
                                decoration: InputDecoration(
                                  hintText: 'Search games...',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: subtitleColor,
                                    height: 1.1,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onSubmitted: (_) => _updateFilteredGames(),
                              ),
                            ),
                          ),
                          // Clear Button (only shows when text exists)
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (context, value, child) {
                              return value.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(Icons.clear, color: subtitleColor, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      _updateFilteredGames();
                                    },
                                  )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter Button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
                          blurRadius: isDarkMode ? 8 : 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: textColor, size: 22),
                      padding: EdgeInsets.zero,
                      onPressed: () => _showFiltersDialog(context),
                    ),
                  ),
                ],
              ),
            ),

            // Suggestions Section - Using Obx for reactive updates
            Obx(() {
              if (_showSuggestions.value && _searchSuggestions.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 14, bottom: 10),
                      child: Text(
                        "Suggestions",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              isDarkMode
                                  ? AppTheme.lightTextColorDarkMode
                                  : AppTheme.lightTextColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _searchSuggestions.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return _buildSuggestionChip(
                            _searchSuggestions[index],
                            isDarkMode,
                            Theme.of(context).colorScheme,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return SizedBox(height: 16);
            }),

            // Content Area (Games Grid or Empty State)
            Expanded(
              child: Obx(() {
                // Convert from Rx to standard list to avoid nested reactive operations
                final games = _filteredGames.toList();

                if (games.isEmpty) {
                  return _buildNoGamesFoundState(isDarkMode);
                } else {
                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      return _buildGameCard(games[index], context, isDarkMode);
                    },
                  );
                }
              }),
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
    final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;
    final textColor = isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor;
    final subtitleColor = isDarkMode ? AppTheme.lightTextColorDarkMode : AppTheme.lightTextColor;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDarkMode ? const Color(0xFF2D3250) : Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: subtitleColor, size: 22),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Players filter section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Number of Players',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${players.value}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Players slider
                  Obx(
                    () => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor:
                            isDarkMode ? const Color(0xFF3D4266) : primaryColor.withOpacity(0.2),
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.1),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        min: 1,
                        max: 30,
                        divisions: 29,
                        value: players.value.toDouble(),
                        onChanged: (value) {
                          players.value = value.round();
                        },
                      ),
                    ),
                  ),

                  // Player range indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1',
                          style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.0),
                        ),
                        Text(
                          '30',
                          style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Maximum Time section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Maximum Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${maxTime.value} min',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Time slider
                  Obx(
                    () => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor:
                            isDarkMode ? const Color(0xFF3D4266) : primaryColor.withOpacity(0.2),
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.1),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        min: 5,
                        max: 120,
                        divisions: 23,
                        value: maxTime.value.toDouble(),
                        onChanged: (value) {
                          maxTime.value = value.round();
                        },
                      ),
                    ),
                  ),

                  // Time range indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5 min',
                          style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.0),
                        ),
                        Text(
                          '120 min',
                          style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Action buttons
              Row(
                children: [
                  // Reset button
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        players.value = 1;
                        maxTime.value = 60;
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(
                            color:
                                isDarkMode
                                    ? const Color(0xFF4D5277)
                                    : primaryColor.withOpacity(0.3),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: primaryColor,
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Apply button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        _minPlayers.value = players.value;
                        _maxTime.value = maxTime.value;
                        _updateFilteredGames();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(Game game, BuildContext context, bool isDarkMode) {
    final textColor = isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor;
    final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDarkMode ? null : Border.all(color: const Color(0xFFEAEFF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.08),
            blurRadius: isDarkMode ? 12 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.GAME_DETAILS, arguments: game),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Image
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildGameImage(game.imageUrl),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Game Details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_rounded, size: 14, color: primaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${game.minPlayers}-${game.maxPlayers}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.timer_rounded, size: 14, color: primaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${game.estimatedTimeMinutes}m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated Empty state widget with "No Games Found" styling but without reset button
  Widget _buildNoGamesFoundState(bool isDarkMode) {
    final textColor = isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor;
    final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category icon in circle
          Obx(() {
            // Get category icon
            IconData categoryIcon = Icons.sports_esports;
            Color iconColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

            // Check category and assign appropriate icon
            final title = _screenTitle.value.toLowerCase();
            if (title.contains('ice breaker')) {
              categoryIcon = Icons.ac_unit_rounded;
              iconColor = isDarkMode ? Colors.lightBlue : Colors.blue;
            } else if (title.contains('team building')) {
              categoryIcon = Icons.people_alt_rounded;
              iconColor = isDarkMode ? Colors.lightGreen : Colors.green;
            } else if (title.contains('brain game')) {
              categoryIcon = Icons.psychology_rounded;
              iconColor = isDarkMode ? Colors.purpleAccent : Colors.purple;
            } else if (title.contains('quick game')) {
              categoryIcon = Icons.speed_rounded;
              iconColor = isDarkMode ? Colors.amber : Colors.orange;
            }

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D3250) : const Color(0xFFF9F9F9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        isDarkMode ? Colors.black.withOpacity(0.3) : primaryColor.withOpacity(0.05),
                    blurRadius: isDarkMode ? 16 : 10,
                    offset: const Offset(0, 6),
                    spreadRadius: isDarkMode ? 2 : 0,
                  ),
                ],
              ),
              child: Center(child: Icon(categoryIcon, size: 48, color: iconColor)),
            );
          }),
          const SizedBox(height: 32),
          // Title
          Text(
            "No Games Found",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // Updated suggestion chip to match the screenshot
  Widget _buildSuggestionChip(String suggestion, bool isDarkMode, ColorScheme colorScheme) {
    final textColor = isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor;
    final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

    return InkWell(
      onTap: () {
        _searchController.text = suggestion;
        _showSuggestions.value = false;
        _updateFilteredGames();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF252842) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
              blurRadius: isDarkMode ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: isDarkMode ? null : Border.all(color: const Color(0xFFEAEFF5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 16, color: primaryColor),
            const SizedBox(width: 6),
            LimitedBox(
              maxWidth: 150,
              child: Text(
                suggestion,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build game image from URL or asset
  Widget _buildGameImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Remote image from URL with improved error handling
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4B7FFF),
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
          return _buildPlaceholderImage();
        },
      );
    } else {
      // Fallback to placeholder image
      return _buildPlaceholderImage();
    }
  }

  // Helper to create placeholder images consistently
  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
    );
  }
}
