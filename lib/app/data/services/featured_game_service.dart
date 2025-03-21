import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_model.dart';
import 'api_config.dart';
import 'gemini_api_service.dart';

class FeaturedGameService {
  final Dio _dio = Dio();
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  // Cache keys
  static const String _cacheKey = 'featured_game_cache';
  static const String _lastFetchTimeKey = 'featured_game_last_fetch';
  static const String _queueKey = 'games_queue_cache';

  // Cache duration: 5 minutes in milliseconds for testing
  static const int _cacheDuration = 5 * 60 * 1000;

  // Timer to track when a featured game should be refreshed
  Timer? _refreshTimer;
  final RxBool isRefreshing = false.obs;

  // Keep track of recently generated games to avoid duplicates
  final List<String> _recentGameIds = [];

  // Getter for the refresh timer
  Timer? get refreshTimer => _refreshTimer;

  // Get the featured game of the day
  Future<Game?> getFeaturedGameOfTheDay() async {
    debugPrint('🔄 Starting getFeaturedGameOfTheDay()');

    // Check if we have a cached game that's still valid
    final cachedGame = await _getCachedFeaturedGame();
    if (cachedGame != null) {
      debugPrint('✅ Returning cached featured game: ${cachedGame.name}');
      _scheduleNextRefresh();
      return cachedGame;
    }

    // If no valid cache, fetch a new game from the API
    try {
      debugPrint('🔄 No valid cache found, fetching new featured game from Gemini API');
      isRefreshing.value = true;
      final game = await _fetchFeaturedGameFromApi();
      isRefreshing.value = false;

      if (game != null) {
        debugPrint('✅ Successfully fetched game from API: ${game.name}');
        // Track this game's ID to avoid duplicates
        _recentGameIds.add(game.id);
        if (_recentGameIds.length > 10) {
          _recentGameIds.removeAt(0); // Keep the list at a reasonable size
        }

        // Cache the new game
        await _cacheFeaturedGame(game);
        _scheduleNextRefresh();
        return game;
      } else {
        debugPrint('❌ API returned null game');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error in getFeaturedGameOfTheDay: $e');
      isRefreshing.value = false;
      return null;
    }
  }

  // Get cached game without triggering a refresh or API call
  Future<Game?> getCachedGameWithoutRefresh() async {
    try {
      final cachedGame = await _getCachedFeaturedGame();
      if (cachedGame != null) {
        debugPrint('✅ Retrieved cached game without refresh: ${cachedGame.name}');
        return cachedGame;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting cached game: $e');
      return null;
    }
  }

  // Check if we have a valid cached game
  Future<Game?> _getCachedFeaturedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have a last fetch time
      final lastFetchTimeStr = prefs.getString(_lastFetchTimeKey);
      if (lastFetchTimeStr == null) return null;

      final lastFetchTime = DateTime.parse(lastFetchTimeStr);
      final now = DateTime.now();
      final difference = now.difference(lastFetchTime).inMilliseconds;

      // If cache has expired, return null
      if (difference > _cacheDuration) {
        debugPrint('Featured game cache expired. Last fetch: $lastFetchTime');
        return null;
      }

      // If cache is still valid, return the cached game
      final gameJson = prefs.getString(_cacheKey);
      if (gameJson == null) return null;

      final gameMap = json.decode(gameJson);
      return Game.fromJson(gameMap);
    } catch (e) {
      debugPrint('Error getting cached featured game: $e');
      return null;
    }
  }

  // Cache the featured game
  Future<void> _cacheFeaturedGame(Game game) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store the game as JSON
      final gameJson = json.encode(game.toJson());
      await prefs.setString(_cacheKey, gameJson);

      // Store the current time as the last fetch time
      final now = DateTime.now().toIso8601String();
      await prefs.setString(_lastFetchTimeKey, now);

      debugPrint('Featured game cached successfully: ${game.name}');
    } catch (e) {
      debugPrint('Error caching featured game: $e');
    }
  }

  // Refresh the featured game (for rotation)
  Future<Game?> refreshFeaturedGame() async {
    try {
      isRefreshing.value = true;
      debugPrint('🔄 Refreshing featured game for rotation');

      // Load existing queue to check for duplicates
      final existingGames = await loadGamesQueue();
      final existingIds = existingGames.map((game) => game.id).toList();

      // Include request for diversity and exclude existing games
      final game = await _fetchFeaturedGameFromApi(
        requestDiversity: true,
        existingGameIds: existingIds,
      );
      isRefreshing.value = false;

      if (game != null) {
        debugPrint('✅ Successfully refreshed featured game: ${game.name}');

        // Add to recent game IDs to avoid duplicates
        _recentGameIds.add(game.id);
        if (_recentGameIds.length > 10) {
          _recentGameIds.removeAt(0);
        }

        return game;
      } else {
        debugPrint('❌ Failed to refresh featured game');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error refreshing featured game: $e');
      isRefreshing.value = false;
      return null;
    }
  }

  // Load games queue from storage
  Future<List<Game>> loadGamesQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);

      if (queueJson != null) {
        final List<dynamic> decodedList = jsonDecode(queueJson);
        final gamesList = decodedList.map((gameJson) => Game.fromJson(gameJson)).toList();
        debugPrint('✅ Loaded ${gamesList.length} games from queue cache');
        return gamesList;
      }
    } catch (e) {
      debugPrint('❌ Error loading games queue: $e');
    }
    return [];
  }

  // Save games queue to storage
  Future<void> saveGamesQueue(List<Game> games) async {
    try {
      if (games.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(games.map((game) => game.toJson()).toList());
      await prefs.setString(_queueKey, queueJson);
      debugPrint('✅ Saved ${games.length} games to queue cache');
    } catch (e) {
      debugPrint('❌ Error saving games queue: $e');
    }
  }

  // Fetch a featured game from the Gemini API
  Future<Game?> _fetchFeaturedGameFromApi({
    bool requestDiversity = false,
    List<String>? existingGameIds,
  }) async {
    try {
      // Get API key from secure storage
      final apiKey = await ApiConfig.getGeminiApiKey();

      // Check if API key is valid
      if (apiKey.startsWith("PLEASE_ADD_YOUR_GEMINI_API_KEY") || apiKey.isEmpty) {
        debugPrint('❌ No API key set. Please add your Gemini API key in Settings.');
        return null;
      }

      debugPrint('🔄 Building prompt for featured game');
      // Build prompt for a featured game
      String prompt = _buildFeaturedGamePrompt(
        requestDiversity: requestDiversity,
        existingGameIds: existingGameIds,
      );

      // Print the complete prompt for debugging
      debugPrint('===== PROMPT TO GEMINI =====');
      debugPrint(prompt);
      debugPrint('===== END PROMPT =====');

      // Print the API URL (masking most of the API key for security)
      final maskedApiKey =
          apiKey.length > 8
              ? "${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}"
              : "***masked***";
      debugPrint('🔄 API URL: $apiUrl?key=$maskedApiKey');

      // Prepare request body
      Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.2,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 8192,
          "responseMimeType": "application/json",
        },
      };

      debugPrint('🔄 Making API request to Gemini');
      // Make API request
      final response = await _dio.post(
        "$apiUrl?key=$apiKey",
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      // Handle response
      if (response.statusCode == 200) {
        debugPrint('✅ Received 200 response from Gemini API');
        try {
          // Print raw API response for debugging
          debugPrint('===== RAW API RESPONSE =====');
          debugPrint(
            "${json.encode(response.data).substring(0, json.encode(response.data).length > 500 ? 500 : json.encode(response.data).length)}<…>",
          );
          debugPrint('===== END RAW RESPONSE =====');

          // Extract the JSON string from the response
          final textValue = response.data['candidates'][0]['content']['parts'][0]['text'];
          debugPrint('🔄 Parsing JSON response');

          // Print parsed JSON for debugging
          debugPrint('===== PARSED JSON FROM GEMINI =====');
          debugPrint(textValue);
          debugPrint('===== END PARSED JSON =====');

          // Parse the JSON string to get the game
          final gameJson = json.decode(textValue);
          Game? game;

          // If we received an array but we only want one game, take the first
          if (gameJson is List && gameJson.isNotEmpty) {
            debugPrint('ℹ️ Received JSON array, taking first game');
            final singleGameJson = gameJson.first;

            // Make sure isFeatured is true
            singleGameJson['isFeatured'] = true;

            // Create the game from JSON
            game = Game.fromJson(singleGameJson);
          }
          // If we received a single object directly
          else if (gameJson is Map<String, dynamic>) {
            debugPrint('ℹ️ Received JSON object directly');
            // Make sure isFeatured is true
            gameJson['isFeatured'] = true;

            // Create the game from JSON
            game = Game.fromJson(gameJson);
          } else {
            // If we got neither a list nor a map, return null
            debugPrint('❌ Unexpected response format from Gemini');
            return null;
          }

          // Get Unsplash image for the game using GeminiApiService
          final geminiApiService = GeminiApiService();
          final processedGame = await geminiApiService.processGameWithUnsplashImage(game);

          debugPrint('✅ Successfully processed game with Unsplash image: ${processedGame?.name}');
          return processedGame;
        } catch (e) {
          debugPrint('❌ Error parsing Gemini response: $e');
          return null;
        }
      } else {
        debugPrint('❌ Error getting featured game: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception in _fetchFeaturedGameFromApi: $e');
      return null;
    }
  }

  // Build the prompt for the featured game
  String _buildFeaturedGamePrompt({bool requestDiversity = false, List<String>? existingGameIds}) {
    String basePrompt = '''
    You are a creative game designer. Create a detailed description of an engaging team-building or icebreaker game activity that would be fun for a group.

    Return ONLY a JSON object with the following structure (without any explanation before or after):
    {
      "id": "generate a random alphanumeric id",
      "name": "Game name",
      "description": "A detailed description of the game",
      "category": "One of: Team-Building, Icebreakers, Brain Games, Quick Games",
      "imageUrl": "a descriptive search query for Unsplash images related to the game",
      "minPlayers": minimum players required (number),
      "maxPlayers": maximum players allowed (number),
      "estimatedTimeMinutes": estimated time to play in minutes (number),
      "instructions": ["Step 1", "Step 2", ...],
      "isFeatured": true,
      "difficultyLevel": "One of: Easy, Medium, Hard",
      "materialsRequired": ["item1", "item2", ...],
      "gameType": "One of: Indoor, Outdoor, Desk-based, Challenge",
      "rating": a number between 3.0 and 5.0,
      "isTimeBound": boolean indicating if game has time limit,
      "teamBased": boolean indicating if game requires teams,
      "rules": ["Rule 1", "Rule 2", ...],
      "howToPlay": "Brief explanation of gameplay"
    }
    
    IMPORTANT: For the imageUrl field, provide a descriptive search query (2-5 words) that can be used to find an appropriate image on Unsplash.
    Examples: "team building outdoors", "office icebreaker game", "puzzle solving group". Don't include actual URLs.
    
    Focus on creating activities that are engaging, easy to explain, and help with team bonding.
    ''';

    // If requesting diversity, add some specific instructions
    if (requestDiversity) {
      basePrompt += '''
      
      IMPORTANT: Create a game that is DIFFERENT from these recent games:
      ${_recentGameIds.isNotEmpty ? 'Recent IDs: ${_recentGameIds.join(', ')}' : 'No recent games yet'}
      ${existingGameIds != null && existingGameIds.isNotEmpty ? 'Existing IDs: ${existingGameIds.join(', ')}' : ''}
      
      Make sure to create a game with a DIFFERENT:
      - Game type (if previous was indoor, try outdoor)
      - Difficulty level (vary between easy, medium, hard)
      - Player count (some for small groups, some for larger groups)
      - Materials required (some should need few materials, others more)
      - Category (mix between Team-Building, Icebreakers, Brain Games, Quick Games)
      
      Ensure the game has a unique name, concept, and ID from any previously mentioned games.
      ''';
    }

    return basePrompt;
  }

  // Schedule the next refresh based on when the cache will expire
  void _scheduleNextRefresh() async {
    try {
      // Cancel any existing timer
      _refreshTimer?.cancel();

      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimeStr = prefs.getString(_lastFetchTimeKey);
      if (lastFetchTimeStr == null) return;

      final lastFetchTime = DateTime.parse(lastFetchTimeStr);
      final now = DateTime.now();
      final difference = now.difference(lastFetchTime).inMilliseconds;

      // Calculate time until next refresh
      final timeUntilRefresh = _cacheDuration - difference;

      if (timeUntilRefresh > 0) {
        debugPrint('⏰ Scheduling next featured game refresh in ${timeUntilRefresh / 1000} seconds');
        _refreshTimer = Timer(Duration(milliseconds: timeUntilRefresh), () {
          debugPrint('⏰ Auto-refresh timer triggered');
          refreshFeaturedGame();
        });
      } else {
        // If the cache has already expired, refresh immediately
        refreshFeaturedGame();
      }
    } catch (e) {
      debugPrint('❌ Error scheduling next refresh: $e');
    }
  }
}
