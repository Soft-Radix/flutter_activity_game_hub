import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app/bindings/app_binding.dart';
import 'app/controllers/bindings/main_binding.dart';
import 'app/controllers/theme_controller.dart';
import 'app/data/models/game_model.dart';
import 'app/data/models/leaderboard_entry_model.dart';
import 'app/data/providers/game_provider.dart';
import 'app/data/providers/gemini_game_provider.dart';
import 'app/data/providers/leaderboard_provider.dart';
import 'app/data/services/featured_game_service.dart';
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

  // Initialize providers
  await initProviders();

  // Register app bindings
  AppBinding().dependencies();

  // Debug print the state of the FeaturedGameService
  try {
    final service = Get.find<FeaturedGameService>();
    debugPrint('🔍 FeaturedGameService found successfully: ${service.hashCode}');
  } catch (e) {
    debugPrint('❌ FeaturedGameService not found: $e');
  }

  // Short delay to ensure all services are registered
  await Future.delayed(const Duration(milliseconds: 100));

  // Try again after delay
  try {
    final service = Get.find<FeaturedGameService>();
    debugPrint('🔍 FeaturedGameService found after delay: ${service.hashCode}');
  } catch (e) {
    debugPrint('❌ FeaturedGameService still not found after delay: $e');
  }

  runApp(const MyApp());
}

// Initialize providers for dependency injection
Future<void> initProviders() async {
  // Initialize providers
  await Get.putAsync(() => GameProvider().init());
  await Get.putAsync(() => GeminiGameProvider().init());
  await Get.putAsync(() => LeaderboardProvider().init());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Activity Game Hub',
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
          themeMode: themeController.themeMode.value,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.cupertino,
          transitionDuration: AppTheme.mediumAnimationDuration,
          initialBinding: MainBinding(),
        );
      },
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
      difficultyLevel: fields[10] as String? ?? 'Easy',
      materialsRequired: fields[11] != null ? (fields[11] as List).cast<String>() : <String>[],
      gameType: fields[12] as String? ?? 'Indoor',
      rating: fields[13] != null ? (fields[13] as num).toDouble() : 3.0,
      isTimeBound: fields[14] as bool? ?? false,
      teamBased: fields[15] as bool? ?? false,
      rules: fields[16] != null ? (fields[16] as List).cast<String>() : <String>[],
      howToPlay: fields[17] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(18)
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
      ..write(obj.isFeatured)
      ..writeByte(10)
      ..write(obj.difficultyLevel)
      ..writeByte(11)
      ..write(obj.materialsRequired)
      ..writeByte(12)
      ..write(obj.gameType)
      ..writeByte(13)
      ..write(obj.rating)
      ..writeByte(14)
      ..write(obj.isTimeBound)
      ..writeByte(15)
      ..write(obj.teamBased)
      ..writeByte(16)
      ..write(obj.rules)
      ..writeByte(17)
      ..write(obj.howToPlay);
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
