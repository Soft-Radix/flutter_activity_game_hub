import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/leaderboard_controller.dart';
import '../../controllers/timer_controller.dart';
import '../../data/models/game_model.dart';
import '../../themes/app_theme.dart';

class TimerScoreboardScreen extends StatefulWidget {
  const TimerScoreboardScreen({super.key});

  @override
  State<TimerScoreboardScreen> createState() => _TimerScoreboardScreenState();
}

class _TimerScoreboardScreenState extends State<TimerScoreboardScreen>
    with SingleTickerProviderStateMixin {
  final TimerController _timerController = Get.find<TimerController>();
  final LeaderboardController _leaderboardController = Get.find<LeaderboardController>();
  late TabController _tabController;
  late Game _game;
  final TextEditingController _teamNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _teams = [];
  String? _winner;
  bool _showAddTeamDialog = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _game = Get.arguments as Game;

    // Reset the timer
    _timerController.resetTimer();
    _timerController.resetScores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  void _addTeam() {
    if (_teams.isEmpty) {
      _showAddTeamDialog = true;
      _showTeamDialog();
    } else {
      _showTeamDialog();
    }
  }

  void _showTeamDialog() {
    _teamNameController.clear();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_showAddTeamDialog ? 'Add Teams or Players' : 'Add Team or Player'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showAddTeamDialog)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Add teams or players to track scores',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  TextFormField(
                    controller: _teamNameController,
                    decoration: const InputDecoration(
                      labelText: 'Team/Player Name',
                      hintText: 'Enter name here',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      if (_teams.contains(value.trim())) {
                        return 'This name already exists';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _teams.add(_teamNameController.text.trim());
                      _timerController.initializeScores(_teams);
                      _showAddTeamDialog = false;
                    });
                    Get.back();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _removeTeam(String team) {
    setState(() {
      _teams.remove(team);
      _timerController.initializeScores(_teams);
    });
  }

  void _startTimer() {
    _timerController.startTimer(_game.estimatedTimeMinutes);
  }

  void _saveScores() {
    if (_teams.isEmpty) {
      Get.snackbar(
        'No Teams Added',
        'Please add at least one team or player to save scores',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check for a winner
    _winner = _timerController.getWinner();
    bool isTie = _timerController.isTie();

    // Show the save score dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save to Leaderboard'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isTie)
                  const Text('The game ended in a tie!')
                else if (_winner != null)
                  Text('${_winner!} won! Save their score to the leaderboard?'),
                const SizedBox(height: 16),
                Text('Game: ${_game.name}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._teams.map((team) {
                  final score = _timerController.scores[team] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(team),
                        Text(
                          '$score points',
                          style: TextStyle(
                            fontWeight: team == _winner ? FontWeight.bold : FontWeight.normal,
                            color: team == _winner ? AppTheme.successColor : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  _saveToLeaderboard();
                  Get.back();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _saveToLeaderboard() {
    for (final team in _teams) {
      final score = _timerController.scores[team] ?? 0;
      _leaderboardController.addEntry(
        playerOrTeamName: team,
        gameId: _game.id,
        gameName: _game.name,
        score: score,
      );
    }

    Get.back();

    Get.snackbar(
      'Scores Saved',
      'Game scores have been saved to the leaderboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_game.name, style: Theme.of(context).textTheme.headlineSmall),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.lightTextColor,
          tabs: const [Tab(text: 'Timer'), Tab(text: 'Scoreboard')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Timer Tab
          _buildTimerTab(),

          // Scoreboard Tab
          _buildScoreboardTab(),
        ],
      ),
      floatingActionButton:
          _tabController.index == 1
              ? FloatingActionButton(
                onPressed: _addTeam,
                tooltip: 'Add Team',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildTimerTab() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timer Display
          Obx(
            () => Container(
              padding: const EdgeInsets.all(AppTheme.padding),
              decoration: BoxDecoration(
                color: _timerController.isRunning.value ? AppTheme.primaryColor : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Time Remaining',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          _timerController.isRunning.value
                              ? Colors.white.withOpacity(0.9)
                              : AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minutes
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _timerController.isRunning.value
                                  ? Colors.white.withOpacity(0.2)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _timerController.minutes.value.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color:
                                _timerController.isRunning.value
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                          ),
                        ),
                      ),

                      // Colon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color:
                                _timerController.isRunning.value
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                          ),
                        ),
                      ),

                      // Seconds
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _timerController.isRunning.value
                                  ? Colors.white.withOpacity(0.2)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _timerController.seconds.value.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color:
                                _timerController.isRunning.value
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Timer Controls
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_timerController.isRunning.value &&
                    (_timerController.minutes.value > 0 || _timerController.seconds.value > 0))
                  ElevatedButton.icon(
                    onPressed: _timerController.resumeTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                else if (!_timerController.isRunning.value)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Timer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _timerController.pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: AppTheme.accentColor,
                    ),
                  ),

                const SizedBox(width: 16),

                OutlinedButton.icon(
                  onPressed: _timerController.resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Game Info Box
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text('Game Info', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: AppTheme.lightTextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Players: ${_game.minPlayers}-${_game.maxPlayers}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: AppTheme.lightTextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Duration: ${_game.estimatedTimeMinutes} minutes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: AppTheme.lightTextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Category: ${_game.category}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _tabController.animateTo(1),
                      icon: const Icon(Icons.scoreboard),
                      label: const Text('Go to Scoreboard'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboardTab() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Column(
        children: [
          // Teams and scores
          Expanded(
            child:
                _teams.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_add, size: 64, color: AppTheme.lightTextColor),
                          const SizedBox(height: 16),
                          Text(
                            'Add Teams or Players',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add teams or players',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : Obx(
                      () => ListView.builder(
                        itemCount: _teams.length,
                        itemBuilder: (context, index) {
                          final team = _teams[index];
                          final score = _timerController.scores[team] ?? 0;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.padding),
                              child: Row(
                                children: [
                                  // Team name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(team, style: Theme.of(context).textTheme.titleMedium),
                                        Text(
                                          'Score: $score',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Score controls
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _timerController.decrementScore(team),
                                        icon: const Icon(Icons.remove_circle),
                                        color: Colors.redAccent,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$score',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _timerController.incrementScore(team),
                                        icon: const Icon(Icons.add_circle),
                                        color: Colors.green,
                                      ),

                                      // Delete team
                                      IconButton(
                                        onPressed: () => _removeTeam(team),
                                        icon: const Icon(Icons.delete),
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),

          // Save scores button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _teams.isEmpty ? null : _saveScores,
              icon: const Icon(Icons.save),
              label: const Text('End Game & Save Scores'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
