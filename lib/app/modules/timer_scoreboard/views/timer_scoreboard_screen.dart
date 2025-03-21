import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/app_theme.dart';
import '../../../utils/shadow_utils.dart';
import '../../../widgets/dark_mode_check.dart';
import '../controllers/timer_scoreboard_controller.dart';

class TimerScoreboardScreen extends GetView<TimerScoreboardController> {
  const TimerScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
              elevation: isDarkMode ? 0 : 2,
              shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05),
              title: Text(
                'Timer & Scoreboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: isDarkMode ? Colors.white : const Color(0xFF3051D3),
                  ),
                  onPressed: () {
                    controller.resetTimer();
                    controller.resetScores();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
                gradient:
                    isDarkMode
                        ? null
                        : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, const Color(0xFFF8F9FE), const Color(0xFFF0F3FA)],
                          stops: const [0.0, 0.4, 1.0],
                        ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Timer display
                    Card(
                      elevation: isDarkMode ? 4 : 0,
                      color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side:
                            isDarkMode
                                ? BorderSide(color: Colors.grey.shade800, width: 1)
                                : BorderSide.none,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Obx(
                                () => Text(
                                  '${controller.minutes.value.toString().padLeft(2, '0')}:${controller.seconds.value.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : const Color(0xFF2D3142),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildTimerButton(
                                    context,
                                    'Set Timer',
                                    Icons.timer,
                                    () => _showTimerDialog(context),
                                    isDarkMode,
                                  ),
                                  const SizedBox(width: 16),
                                  Obx(
                                    () => _buildTimerButton(
                                      context,
                                      controller.isRunning.value ? 'Pause' : 'Resume',
                                      controller.isRunning.value ? Icons.pause : Icons.play_arrow,
                                      controller.isRunning.value
                                          ? controller.pauseTimer
                                          : () => controller.resumeTimer(),
                                      isDarkMode,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Team management
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                      child: Row(
                        children: [
                          Text(
                            'Teams',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? const Color(0xFF3051D3)
                                      : const Color(0xFF4A6FFF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color: isDarkMode ? Colors.white : const Color(0xFF3051D3),
                              ),
                              onPressed: () => _showAddTeamDialog(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scoreboard
                    Expanded(
                      child: Obx(
                        () =>
                            controller.teams.isEmpty
                                ? _buildEmptyTeamState(context, isDarkMode)
                                : ListView.builder(
                                  itemCount: controller.teams.length,
                                  itemBuilder: (context, index) {
                                    final team = controller.teams[index];
                                    return _buildTeamScoreCard(context, team, index, isDarkMode);
                                  },
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

  Widget _buildTimerButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppTheme.primaryColorDarkMode : const Color(0xFF3051D3),
          foregroundColor: Colors.white,
          elevation: isDarkMode ? 4 : 0,
          shadowColor:
              isDarkMode ? Colors.black.withOpacity(0.3) : const Color(0xFF3051D3).withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTeamScoreCard(BuildContext context, String team, int index, bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 2 : 0,
      color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isDarkMode
                  ? []
                  : ShadowUtils.getLightModeCardShadow(
                    opacity: 0.06,
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: _getTeamColor(index, isDarkMode),
            child: Text(
              team.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            team,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppTheme.textColor,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildScoreButton(
                Icons.remove,
                () => controller.decrementScore(team),
                isDarkMode,
                isIncrement: false,
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black.withOpacity(0.2) : const Color(0xFFF0F3FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${controller.scores[team]}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF3051D3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildScoreButton(
                Icons.add,
                () => controller.incrementScore(team),
                isDarkMode,
                isIncrement: true,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: isDarkMode ? Colors.red.shade300 : Colors.red.shade300,
                ),
                onPressed: () => controller.removeTeam(team),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreButton(
    IconData icon,
    VoidCallback onPressed,
    bool isDarkMode, {
    bool isIncrement = true,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? (isIncrement
                    ? const Color(0xFF3051D3).withOpacity(0.2)
                    : Colors.red.withOpacity(0.2))
                : (isIncrement ? const Color(0xFF4A6FFF).withOpacity(0.1) : Colors.red.shade50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 20,
          color:
              isDarkMode
                  ? (isIncrement ? AppTheme.primaryColorDarkMode : Colors.red.shade300)
                  : (isIncrement ? const Color(0xFF3051D3) : Colors.red.shade400),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEmptyTeamState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF393F5F) : const Color(0xFFF0F3FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group,
              size: 36,
              color: isDarkMode ? const Color(0xFF78A9FF) : const Color(0xFF3051D3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No teams added yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add teams to keep score of the game',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.white70 : Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddTeamDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Team'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? AppTheme.primaryColorDarkMode : const Color(0xFF3051D3),
              foregroundColor: Colors.white,
              elevation: isDarkMode ? 4 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTeamColor(int index, bool isDarkMode) {
    final colors =
        isDarkMode
            ? [
              const Color(0xFF4A6FFF),
              const Color(0xFF00BCD4),
              const Color(0xFF8E24AA),
              const Color(0xFFFF9800),
              const Color(0xFF4CAF50),
            ]
            : [
              const Color(0xFF3051D3),
              const Color(0xFF00ACC1),
              const Color(0xFF7B1FA2),
              const Color(0xFFEF6C00),
              const Color(0xFF388E3C),
            ];

    return colors[index % colors.length];
  }

  void _showTimerDialog(BuildContext context) {
    final TextEditingController minutesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Set Timer'),
        content: TextField(
          controller: minutesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            hintText: 'Enter duration in minutes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text);
              if (minutes != null && minutes > 0) {
                controller.startTimer(minutes);
                Get.back();
              } else {
                Get.snackbar(
                  'Invalid Input',
                  'Please enter a valid number of minutes',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3051D3),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context) {
    final TextEditingController teamNameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Team'),
        content: TextField(
          controller: teamNameController,
          decoration: const InputDecoration(labelText: 'Team Name', hintText: 'Enter team name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              final teamName = teamNameController.text.trim();
              if (teamName.isNotEmpty) {
                controller.addTeam(teamName);
                Get.back();
              } else {
                Get.snackbar(
                  'Invalid Input',
                  'Please enter a team name',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3051D3),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
