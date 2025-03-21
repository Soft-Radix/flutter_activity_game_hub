import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_model.dart';
import 'api_config.dart';

class FeaturedGameService {
  final Dio _dio = Dio();
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  // Cache key for storing the featured game
  static const String _cacheKey = 'featured_game_cache';
  static const String _lastFetchTimeKey = 'featured_game_last_fetch';

  // Cache duration: 10 minutes in milliseconds (changed from 4 hours)
  static const int _cacheDuration = 10 * 60 * 1000;

  // Timer to track when a featured game should be refreshed
  Timer? _refreshTimer;
  final RxBool isRefreshing = false.obs;

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

  // Fetch a featured game from the Gemini API
  Future<Game?> _fetchFeaturedGameFromApi() async {
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
      String prompt = _buildFeaturedGamePrompt();

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

          // If we received an array but we only want one game, take the first
          if (gameJson is List && gameJson.isNotEmpty) {
            debugPrint('ℹ️ Received JSON array, taking first game');
            final singleGameJson = gameJson.first;

            // Make sure isFeatured is true
            singleGameJson['isFeatured'] = true;

            // Process imageUrl
            if (singleGameJson['imageUrl'] != null &&
                singleGameJson['imageUrl'].toString().isNotEmpty &&
                !singleGameJson['imageUrl'].toString().startsWith('assets/') &&
                !singleGameJson['imageUrl'].toString().startsWith('http')) {
              singleGameJson['imageUrl'] = 'https://${singleGameJson['imageUrl']}';
            } else if (singleGameJson['imageUrl'] == null ||
                singleGameJson['imageUrl'].toString().isEmpty) {
              singleGameJson['imageUrl'] = 'assets/images/placeholder.svg';
            }

            debugPrint('✅ Successfully created Game object from JSON array');
            return Game.fromJson(singleGameJson);
          }
          // If we received a single object directly
          else if (gameJson is Map<String, dynamic>) {
            debugPrint('ℹ️ Received JSON object directly');
            // Make sure isFeatured is true
            gameJson['isFeatured'] = true;

            // Process imageUrl
            if (gameJson['imageUrl'] != null &&
                gameJson['imageUrl'].toString().isNotEmpty &&
                !gameJson['imageUrl'].toString().startsWith('assets/') &&
                !gameJson['imageUrl'].toString().startsWith('http')) {
              gameJson['imageUrl'] = 'https://${gameJson['imageUrl']}';
            } else if (gameJson['imageUrl'] == null || gameJson['imageUrl'].toString().isEmpty) {
              gameJson['imageUrl'] = 'assets/images/placeholder.svg';
            }

            debugPrint('✅ Successfully created Game object from JSON object');
            return Game.fromJson(gameJson);
          }

          // If we got neither a list nor a map, return null
          debugPrint('❌ Unexpected response format from Gemini');
          return null;
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

  // Build a prompt specifically for a featured game
  String _buildFeaturedGamePrompt() {
    return '''
    Generate a list of activity games in JSON format.
    Each game should include id, name, description, category, imageUrl, minPlayers, maxPlayers, estimatedTimeMinutes,
    instructions (as array of strings), isFeatured, difficultyLevel, materialsRequired (as array of strings),
    gameType, rating, isTimeBound, teamBased, rules (as array of strings), and howToPlay.

    Return the response as a valid JSON array only, without any additional text, explanation, or markdown formatting.
    Do not include any text before or after the JSON array.


Provide exactly 5 games in the response.
''';
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

  // Force refresh the featured game cache
  Future<Game?> refreshFeaturedGame() async {
    if (isRefreshing.value) {
      debugPrint('⚠️ Already refreshing, ignoring duplicate request');
      return null;
    }

    try {
      isRefreshing.value = true;
      debugPrint('🔄 Starting cache clearance in FeaturedGameService.refreshFeaturedGame()');
      // Clear the current cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastFetchTimeKey);
      debugPrint('✅ Cache cleared successfully');

      // Fetch a new game
      debugPrint('🔄 Fetching new featured game after cache clearance');
      final game = await getFeaturedGameOfTheDay();

      if (game != null) {
        debugPrint('✅ Successfully fetched new featured game: ${game.name}');
      } else {
        debugPrint('❌ Failed to fetch new featured game after cache clearance');
      }

      return game;
    } catch (e) {
      debugPrint('❌ Error in FeaturedGameService.refreshFeaturedGame(): $e');
      return null;
    } finally {
      isRefreshing.value = false;
    }
  }
}
