import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/theme_controller.dart';
import '../../../data/models/game_model.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/dark_mode_check.dart';
import '../controllers/game_details_controller.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Game game = Get.arguments as Game;
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenSize = MediaQuery.of(context).size;

    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
              elevation: isDarkMode ? 0 : 2,
              shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
                onPressed: () => Get.back(),
              ),
              title: Text(
                game.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share, color: isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () {
                    Get.snackbar(
                      'Share',
                      'Sharing functionality would be implemented here',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                      colorText: isDarkMode ? Colors.white : Colors.black87,
                    );
                  },
                  tooltip: 'Share this game',
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Image with blue background (updated to match screenshot)
                  Stack(
                    children: [
                      Container(
                        height: screenSize.height * 0.25, // Responsive height
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [const Color(0xFF4A6FFF), const Color(0xFF3051D3)],
                          ),
                        ),
                        child: Hero(
                          tag: 'game-image-${game.id}',
                          child: Center(
                            child: Container(
                              height: screenSize.height * 0.12,
                              width: screenSize.height * 0.12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(child: _buildGameImage(game.imageUrl, isDarkMode)),
                            ),
                          ),
                        ),
                      ),

                      // Rating on bottom left and difficulty on bottom right (similar to screenshot)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 22),
                              const SizedBox(width: 4),
                              Text(
                                '${game.rating}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Difficulty badge bottom right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(game.difficultyLevel),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getDifficultyIcon(game.difficultyLevel),
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                game.difficultyLevel,
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Category and player info (updated to match screenshot)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Second row with Game Type
                      ],
                    ),
                  ),

                  // Game features (Competitive, Time Bound, Team Based) - similar to screenshot
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeatureItem(
                              Icons.category_outlined,
                              'Competitive',
                              Colors.blue,
                              textTheme,
                              isDarkMode,
                            ),
                            _buildFeatureItem(
                              game.isTimeBound ? Icons.timer : Icons.timer_off,
                              'Time Bound',
                              game.isTimeBound ? Colors.orange : Colors.grey,
                              textTheme,
                              isDarkMode,
                            ),
                            _buildFeatureItem(
                              game.teamBased ? Icons.group : Icons.person,
                              'Team Based',
                              game.teamBased ? Colors.green : Colors.purple,
                              textTheme,
                              isDarkMode,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Key game parameters
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            _buildGameTag(
                              "Category: ${game.category}",
                              Icons.category,
                              Colors.purple,
                              textTheme,
                              isDarkMode,
                            ),
                            _buildGameTag(
                              "Difficulty: ${game.difficultyLevel}",
                              _getDifficultyIcon(game.difficultyLevel),
                              _getDifficultyColor(game.difficultyLevel),
                              textTheme,
                              isDarkMode,
                            ),
                            _buildGameTag(
                              "Game Type: ${game.gameType}",
                              Icons.sports_esports,
                              Colors.green,
                              textTheme,
                              isDarkMode,
                            ),
                            _buildGameTag(
                              "Players: ${game.minPlayers}-${game.maxPlayers}",
                              Icons.people,
                              Colors.blue,
                              textTheme,
                              isDarkMode,
                            ),
                            _buildGameTag(
                              "Time: ${game.estimatedTimeMinutes} min",
                              Icons.timer,
                              Colors.orange,
                              textTheme,
                              isDarkMode,
                            ),
                            if (game.isFeatured)
                              _buildGameTag(
                                "Featured",
                                Icons.star,
                                Colors.amber,
                                textTheme,
                                isDarkMode,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // How to Play Overview section
                  if (game.howToPlay.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Play Overview',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            game.howToPlay,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Description section
                  if (game.description.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            game.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Materials Required - Improved to handle long text
                  if (game.materialsRequired.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Materials Required',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Updated Wrap widget with improved material items
                          Wrap(
                            children:
                                game.materialsRequired
                                    .map(
                                      (material) =>
                                          _buildMaterialItem(material, textTheme, isDarkMode),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),

                  // How to Play section
                  if (game.instructions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Play',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInstructionsList(game.instructions, textTheme, isDarkMode),
                        ],
                      ),
                    ),

                  // Rules section (if present)
                  if (game.rules.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Game Rules',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRulesList(game.rules, textTheme, isDarkMode),
                        ],
                      ),
                    ),

                  // Winner & Elimination Rules Section - moved to the end
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              color: isDarkMode ? Colors.amber : Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Winner & Elimination Rules',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Winner information
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF303450) : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? Colors.blue.shade800 : Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? Colors.blue.shade900.withOpacity(0.3)
                                          : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Winner Condition',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDarkMode
                                                ? Colors.blue.shade300
                                                : Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                game.winnerGamePlayerOrTeam.isNotEmpty
                                    ? game.winnerGamePlayerOrTeam
                                    : 'The team or player who successfully completes the objective first.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Out of Play Rules
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF303450) : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? Colors.orange.shade800 : Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? Colors.orange.shade900.withOpacity(0.3)
                                          : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Elimination Rules',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDarkMode
                                                ? Colors.orange.shade300
                                                : Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              game.outOfPlayRules.isNotEmpty
                                  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:
                                        game.outOfPlayRules.map((rule) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(top: 4),
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.orange.withOpacity(0.2)
                                                            : Colors.orange.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.block,
                                                    size: 10,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.orange.shade300
                                                            : Colors.orange.shade800,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    rule,
                                                    style: textTheme.bodyMedium?.copyWith(
                                                      color:
                                                          isDarkMode
                                                              ? Colors.white
                                                              : Colors.black87,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  )
                                  : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'No elimination rules specified for this game.',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add bottom padding to ensure content isn't cut off
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Add Start and Leaderboard buttons at the bottom
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Leaderboard button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Leaderboard',
                          'Leaderboard functionality would be implemented here',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                          colorText: isDarkMode ? Colors.white : Colors.black87,
                        );
                      },
                      icon: const Icon(Icons.leaderboard, color: Colors.white),
                      label: Text(
                        'Leaderboard',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Start game button
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _onStartGame,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        'Start Game',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6FFF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildGameImage(String imageUrl, bool isDarkMode) {
    // Handle SVG files (local assets)
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imageUrl,
        fit: BoxFit.contain,
        placeholderBuilder:
            (context) => Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(Icons.hide_image, size: 80, color: Color(0xFF4A6FFF)),
              ),
            ),
      );
    }
    // Handle remote URLs
    else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder:
            (ctx, error, stackTrace) => Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(Icons.hide_image, size: 80, color: Color(0xFF4A6FFF)),
              ),
            ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            color: Colors.transparent,
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF4A6FFF))),
          );
        },
      );
    }
    // Handle local asset images
    else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder:
            (ctx, error, stackTrace) => Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(Icons.hide_image, size: 80, color: Color(0xFF4A6FFF)),
              ),
            ),
      );
    }
  }

  Widget _buildInstructionsList(List<String> instructions, TextTheme textTheme, bool isDarkMode) {
    return Column(
      children: List.generate(instructions.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == instructions.length - 1 ? 0 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF3051D3).withOpacity(0.2)
                          : const Color(0xFFEFF1FD),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: textTheme.titleSmall?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    instructions[index],
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRulesList(List<String> rules, TextTheme textTheme, bool isDarkMode) {
    return Column(
      children: List.generate(rules.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == rules.length - 1 ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: isDarkMode ? Colors.white70 : Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rules[index],
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOutOfPlayRulesList(
    List<String> outOfPlayRules,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    return Column(
      children: List.generate(outOfPlayRules.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == outOfPlayRules.length - 1 ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.amber.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block, // Using block icon to emphasize "out of play"
                  size: 12,
                  color: isDarkMode ? Colors.amber : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  outOfPlayRules[index],
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.amber[200] : Colors.orange[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _getDifficultyColor(String difficultyLevel) {
    // Implement your logic to determine the color based on the difficulty level
    // For example, you can use a switch statement or a map to return the appropriate color
    switch (difficultyLevel) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon(String difficultyLevel) {
    // Implement your logic to determine the icon based on the difficulty level
    // For example, you can use a switch statement or a map to return the appropriate icon
    switch (difficultyLevel) {
      case 'Easy':
        return Icons.check_circle;
      case 'Medium':
        return Icons.help;
      case 'Hard':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    Color color,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String label,
    Color color,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
      ],
    );
  }

  // Build materials required section with better handling of long text
  Widget _buildMaterialItem(String material, TextTheme textTheme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF3051D3).withOpacity(0.2) : const Color(0xFFEFF1FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDarkMode
                  ? const Color(0xFF3051D3).withOpacity(0.3)
                  : const Color(0xFF4A6FFF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: isDarkMode ? Colors.white70 : Colors.blue.shade700,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                material,
                style: textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStartGame() {
    final gameDetailsController = Get.find<GameDetailsController>();
    Get.toNamed('/game-play', arguments: gameDetailsController.game.value);
  }

  // NEW: Helper method to build a game tag
  Widget _buildGameTag(
    String label,
    IconData icon,
    Color color,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Color.alphaBlend(color.withOpacity(0.15), const Color(0xFF303450))
                : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? color.withOpacity(0.3) : color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
