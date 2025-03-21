import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/app_theme.dart';
import '../../../utils/shadow_utils.dart';
import '../../../widgets/dark_mode_check.dart';
import '../controllers/game_play_controller.dart';

class GamePlayScreen extends GetView<GamePlayController> {
  const GamePlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
            body: Obx(() {
              if (controller.game.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final game = controller.game.value!;

              return SafeArea(
                child: Column(
                  children: <Widget>[
                    // Game header
                    _buildGameHeader(context, game, isDarkMode),

                    // Main content
                    Expanded(
                      child:
                          controller.isGameStarted.value
                              ? _buildGameInProgress(context, game, isDarkMode)
                              : _buildGameSetupScreen(context, game, isDarkMode),
                    ),
                  ],
                ),
              );
            }),
          ),
    );
  }

  Widget _buildGameHeader(BuildContext context, final game, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
        boxShadow:
            isDarkMode
                ? <BoxShadow>[]
                : <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(
        children: <Widget>[
          // Top bar with back button and game name
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Text(
                  game.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: isDarkMode ? Colors.white70 : Colors.black54),
                onPressed: () => _showGameInfoDialog(context, game, isDarkMode),
              ),
            ],
          ),

          // Timer display if game is in progress and time-bound
          Obx(() {
            if (controller.isCountingDown.value) {
              // Countdown UI
              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3051D3),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF3051D3).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${controller.countdownValue.value}",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            } else if (controller.isGameStarted.value && game.isTimeBound) {
              // Enhanced timer display
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? const Color(0xFF3051D3).withOpacity(0.2)
                            : const Color(0xFFEFF1FD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? const Color(0xFF3051D3).withOpacity(0.3)
                              : const Color(0xFF3051D3).withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow:
                        isDarkMode
                            ? <BoxShadow>[]
                            : <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.timer,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF3051D3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${controller.minutes.value.toString().padLeft(2, '0')}:${controller.seconds.value.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF3051D3),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (controller.isRunning.value)
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? Colors.white.withOpacity(0.1)
                                          : const Color(0xFF3051D3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.pause,
                                  color: isDarkMode ? Colors.white70 : const Color(0xFF3051D3),
                                  size: 18,
                                ),
                              ),
                              onPressed: controller.pauseTimer,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          else
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? Colors.white.withOpacity(0.1)
                                          : const Color(0xFF3051D3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: isDarkMode ? Colors.white70 : const Color(0xFF3051D3),
                                  size: 18,
                                ),
                              ),
                              onPressed: controller.resumeTimer,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      // Timer progress indicator
                      if (game.estimatedTimeMinutes > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _calculateTimerProgress(),
                              backgroundColor:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                              minHeight: 4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildGameSetupScreen(BuildContext context, final game, bool isDarkMode) {
    final List<Widget> setupWidgets = <Widget>[
      // Game image
      Card(
        elevation: isDarkMode ? 4 : 0,
        color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                isDarkMode
                    ? <BoxShadow>[]
                    : ShadowUtils.getEnhancedContainerShadow(
                      opacity: 0.08,
                      blurRadius: 25,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
          ),
          width: double.infinity,
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildGameImage(game.imageUrl, isDarkMode),
          ),
        ),
      ),
      const SizedBox(height: 20),

      // Game description
      Text(
        'Description',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        game.description,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.white70 : Colors.black87),
      ),
      const SizedBox(height: 20),

      // Materials needed
      Text(
        'Materials Needed',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
        ),
      ),
      const SizedBox(height: 12),

      // Materials checklist
      Card(
        elevation: isDarkMode ? 4 : 0,
        color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isDarkMode
                    ? <BoxShadow>[]
                    : ShadowUtils.getLightModeCardShadow(
                      opacity: 0.06,
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                // Column with generated CheckboxListTiles
                Column(
                  children: List.generate(game.materialsRequired.length, (index) {
                    final material = game.materialsRequired[index];
                    return Obx(
                      () => CheckboxListTile(
                        title: Text(
                          material,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        value: controller.checkedMaterials[material] ?? false,
                        onChanged: (_) => controller.toggleMaterialChecked(material),
                        activeColor: const Color(0xFF3051D3),
                        checkColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 30),
    ];

    // Add players section if minimum players is greater than 0
    if ((game.minPlayers ?? 0) > 0) {
      setupWidgets.addAll(<Widget>[
        Text(
          'Players',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Add at least ${game.minPlayers} player(s)',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddPlayersDialog(context, isDarkMode),
              icon: Icon(
                Icons.add,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                size: 18,
              ),
              label: Text(
                'Add Players',
                style: TextStyle(color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Players list
        Builder(
          builder: (context) {
            return Obx(() {
              final playersList = controller.players;

              if (playersList.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No players added yet',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                return Card(
                  elevation: isDarkMode ? 4 : 0,
                  color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        isDarkMode
                            ? BorderSide(color: Colors.grey.shade800, width: 1)
                            : BorderSide.none,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          isDarkMode
                              ? <BoxShadow>[]
                              : ShadowUtils.getLightModeCardShadow(
                                opacity: 0.06,
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                    ),
                    child: Column(
                      children: List.generate(playersList.length, (index) {
                        final player = playersList[index];
                        // Add a divider between items except for the last one
                        if (index > 0) {
                          return Column(
                            children: [
                              Divider(
                                color:
                                    isDarkMode
                                        ? Colors.grey.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.2),
                                height: 1,
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getPlayerColor(index),
                                  child: Text(
                                    player.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  player,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: isDarkMode ? Colors.white60 : Colors.black45,
                                    size: 18,
                                  ),
                                  onPressed: () => controller.removePlayer(player),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getPlayerColor(index),
                              child: Text(
                                player.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              player,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDarkMode ? Colors.white60 : Colors.black45,
                                size: 18,
                              ),
                              onPressed: () => controller.removePlayer(player),
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                );
              }
            });
          },
        ),
        const SizedBox(height: 30),
      ]);
    }

    // Add start game button
    setupWidgets.add(
      Center(
        child: SizedBox(
          width: double.infinity,
          child: Builder(
            builder: (context) {
              return Obx(() {
                final allMaterialsChecked = controller.areAllMaterialsChecked();
                final playersCondition = controller.players.length >= (game.minPlayers ?? 0);
                final isEnabled = allMaterialsChecked && playersCondition;

                return ElevatedButton(
                  onPressed: isEnabled ? controller.startGame : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3051D3),
                    foregroundColor: Colors.white,
                    elevation: isDarkMode ? 4 : 2,
                    shadowColor:
                        isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : const Color(0xFF3051D3).withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor:
                        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.play_circle_outline, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'START GAME',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isEnabled
                                  ? Colors.white
                                  : (isDarkMode ? Colors.white70 : Colors.grey.shade600),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.from(setupWidgets),
      ),
    );
  }

  Widget _buildGameInProgress(BuildContext context, final game, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Current round display
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF3051D3).withOpacity(0.2) : const Color(0xFFEFF1FD),
                borderRadius: BorderRadius.circular(24),
                boxShadow:
                    isDarkMode
                        ? <BoxShadow>[]
                        : <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Obx(
                () => Text(
                  'Round ${controller.currentRound.value}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF3051D3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Game instructions
          Text(
            'Instructions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),

          // Instructions list
          Card(
            elevation: isDarkMode ? 4 : 0,
            color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side:
                  isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    isDarkMode
                        ? <BoxShadow>[]
                        : ShadowUtils.getLightModeCardShadow(
                          opacity: 0.06,
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildInstructionsList(
                  game.instructions,
                  Theme.of(context).textTheme,
                  isDarkMode,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // How to play section
          Text(
            'How to Play',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: isDarkMode ? 4 : 0,
            color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side:
                  isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    isDarkMode
                        ? <BoxShadow>[]
                        : ShadowUtils.getLightModeCardShadow(
                          opacity: 0.06,
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  game.howToPlay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Game controls
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed:
                        controller.isGamePaused.value
                            ? controller.resumeGame
                            : controller.pauseGame,
                    icon: Icon(controller.isGamePaused.value ? Icons.play_arrow : Icons.pause),
                    label: Text(controller.isGamePaused.value ? 'Resume' : 'Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? AppTheme.primaryColorDarkMode : const Color(0xFF3051D3),
                      foregroundColor: Colors.white,
                      elevation: isDarkMode ? 4 : 0,
                      shadowColor:
                          isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : const Color(0xFF3051D3).withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.nextRound,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Next Round'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? const Color(0xFF78A9FF) : const Color(0xFF4A6FFF),
                    foregroundColor: Colors.white,
                    elevation: isDarkMode ? 4 : 0,
                    shadowColor:
                        isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : const Color(0xFF4A6FFF).withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.completeGame,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('COMPLETE GAME'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? const Color(0xFF558B2F) : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: isDarkMode ? 4 : 0,
                shadowColor:
                    isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : const Color(0xFF4CAF50).withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameImage(String imageUrl, bool isDarkMode) {
    // Check if the URL is empty or null
    if (imageUrl.isEmpty) {
      return Container(
        color: isDarkMode ? Colors.black26 : const Color(0xFFF0F3FA),
        child: Center(
          child: Icon(
            Icons.hide_image,
            size: 80,
            color: isDarkMode ? Colors.white30 : const Color(0xFF4A6FFF).withOpacity(0.3),
          ),
        ),
      );
    }

    // Check if it's a network image (remote URL)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (ctx, error, stackTrace) => Container(
              color: isDarkMode ? Colors.black26 : const Color(0xFFF0F3FA),
              child: Center(
                child: Icon(
                  Icons.hide_image,
                  size: 80,
                  color: isDarkMode ? Colors.white30 : const Color(0xFF4A6FFF).withOpacity(0.3),
                ),
              ),
            ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            color: isDarkMode ? Colors.black26 : const Color(0xFFF0F3FA),
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF4A6FFF))),
          );
        },
      );
    }
    // Handle local asset images
    else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (ctx, error, stackTrace) => Container(
              color: isDarkMode ? Colors.black26 : const Color(0xFFF0F3FA),
              child: Center(
                child: Icon(
                  Icons.hide_image,
                  size: 80,
                  color: isDarkMode ? Colors.white30 : const Color(0xFF4A6FFF).withOpacity(0.3),
                ),
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
                  boxShadow: <BoxShadow>[
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

  void _showGameInfoDialog(BuildContext context, final game, bool isDarkMode) {
    Get.dialog(
      AlertDialog(
        title: Text(
          game.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game type
              _buildInfoRow(context, 'Game Type', game.gameType, Icons.category, isDarkMode),
              const SizedBox(height: 12),

              // Difficulty
              _buildInfoRow(
                context,
                'Difficulty',
                game.difficultyLevel,
                _getDifficultyIcon(game.difficultyLevel),
                isDarkMode,
                valueColor: _getDifficultyColor(game.difficultyLevel),
              ),
              const SizedBox(height: 12),

              // Player count
              _buildInfoRow(
                context,
                'Players',
                '${game.minPlayers} - ${game.maxPlayers}',
                Icons.people,
                isDarkMode,
              ),
              const SizedBox(height: 12),

              // Estimated time
              _buildInfoRow(
                context,
                'Time',
                '${game.estimatedTimeMinutes} mins',
                Icons.timer,
                isDarkMode,
              ),
              const SizedBox(height: 12),

              // Team based
              _buildInfoRow(
                context,
                'Team Based',
                game.teamBased ? 'Yes' : 'No',
                Icons.groups,
                isDarkMode,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: TextStyle(color: isDarkMode ? Colors.white70 : const Color(0xFF3051D3)),
            ),
          ),
        ],
        backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDarkMode, {
    Color? valueColor,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: isDarkMode ? Colors.white70 : Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getDifficultyIcon(String difficultyLevel) {
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

  Color _getDifficultyColor(String difficultyLevel) {
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

  // Show dialog to add players
  void _showAddPlayersDialog(BuildContext context, bool isDarkMode) {
    final TextEditingController textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Add Players',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: textController,
              onChanged: controller.updateNewPlayerName,
              decoration: InputDecoration(
                hintText: 'Enter player name',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black38),
                filled: true,
                fillColor:
                    isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.person_add,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.addPlayer(value);
                  textController.clear();
                }
              },
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                return Obx(() {
                  final playersList = controller.players;
                  return playersList.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Current Players:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(playersList.length, (index) {
                                  final player = playersList[index];
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: _getPlayerColor(index),
                                      child: Text(
                                        player.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      player,
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: isDarkMode ? Colors.white60 : Colors.black45,
                                      ),
                                      onPressed: () => controller.removePlayer(player),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      );
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'CANCEL',
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey.shade700),
            ),
          ),
          Builder(
            builder: (context) {
              return Obx(() {
                final newPlayerName = controller.newPlayerName.value;
                final isEnabled = newPlayerName.isNotEmpty;

                return TextButton(
                  onPressed:
                      isEnabled
                          ? () {
                            controller.addPlayer(newPlayerName);
                            textController.clear();
                          }
                          : null,
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      color:
                          isEnabled
                              ? (isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700)
                              : (isDarkMode ? Colors.white30 : Colors.grey.shade400),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              });
            },
          ),
        ],
        backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Get color for player avatar
  Color _getPlayerColor(int index) {
    final List<Color> colors = <Color>[
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  // Calculate timer progress for the progress bar
  double _calculateTimerProgress() {
    if (controller.game.value == null || controller.game.value!.estimatedTimeMinutes <= 0) {
      return 0.0;
    }

    final totalSeconds = controller.game.value!.estimatedTimeMinutes * 60;
    final remainingSeconds = (controller.minutes.value * 60) + controller.seconds.value;

    return 1.0 - (remainingSeconds / totalSeconds);
  }

  // Get appropriate color for timer based on remaining time
  Color _getTimerColor() {
    final progress = _calculateTimerProgress();

    if (progress < 0.7) {
      return Colors.green;
    } else if (progress < 0.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
