import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app/controllers/app_controller.dart';
import 'app/controllers/leaderboard_controller.dart';
import 'app/controllers/navigation_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/controllers/timer_controller.dart';
import 'app/data/models/game_model.dart';
import 'app/data/models/leaderboard_entry_model.dart';
import 'app/data/providers/game_provider.dart';
import 'app/data/providers/leaderboard_provider.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register Hive adapters
  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(LeaderboardEntryAdapter());

  // Initialize services
  await initServices();

  runApp(const MyApp());
}

// Initialize services for dependency injection
Future<void> initServices() async {
  // Initialize providers
  final gameProvider = await Get.putAsync(() => GameProvider().init());
  final leaderboardProvider = await Get.putAsync(() => LeaderboardProvider().init());

  // Initialize controllers
  Get.put(ThemeController());
  Get.put(AppController());
  Get.put(LeaderboardController());
  Get.put(TimerController());
  Get.put(NavigationController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Activity Game Hub',
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: themeController.themeMode.value,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.cupertino,
        transitionDuration: AppTheme.mediumAnimationDuration,
      ),
    );
  }
}

// Hive adapters for our models
class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 0;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      imageUrl: fields[4] as String,
      minPlayers: fields[5] as int,
      maxPlayers: fields[6] as int,
      estimatedTimeMinutes: fields[7] as int,
      instructions: (fields[8] as List).cast<String>(),
      isFeatured: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.minPlayers)
      ..writeByte(6)
      ..write(obj.maxPlayers)
      ..writeByte(7)
      ..write(obj.estimatedTimeMinutes)
      ..writeByte(8)
      ..write(obj.instructions)
      ..writeByte(9)
      ..write(obj.isFeatured);
  }
}

class LeaderboardEntryAdapter extends TypeAdapter<LeaderboardEntry> {
  @override
  final int typeId = 1;

  @override
  LeaderboardEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaderboardEntry(
      id: fields[0] as String,
      playerOrTeamName: fields[1] as String,
      gameId: fields[2] as String,
      gameName: fields[3] as String,
      score: fields[4] as int,
      datePlayed: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playerOrTeamName)
      ..writeByte(2)
      ..write(obj.gameId)
      ..writeByte(3)
      ..write(obj.gameName)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.datePlayed);
  }
}
