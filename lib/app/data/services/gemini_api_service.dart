import 'dart:convert';
import 'dart:math' as Math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/game_model.dart';
import 'api_config.dart';

class GeminiApiService {
  final Dio _dio = Dio();
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  // Add a static variable to store the last API response
  static String lastRawResponse = "";
  static String lastParsedJson = "";
  static String lastPrompt = "";

  // Add a method to print the stored API response
  void printLastApiResponse() {
    debugPrint('===== GEMINI RAW API RESPONSE =====');
    debugPrint(lastRawResponse);
    debugPrint('===== END RAW RESPONSE =====');

    debugPrint('===== GEMINI PARSED JSON =====');
    debugPrint(lastParsedJson);
    debugPrint('===== END PARSED JSON =====');

    // Show a dialog with the API details
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title
              Row(
                children: [
                  const Icon(Icons.api, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Gemini API Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const Divider(),

              // API URL
              Text('API URL:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(apiUrl, style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
              const SizedBox(height: 16),

              // API Response tabs
              DefaultTabController(
                length: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Prompt'),
                        Tab(text: 'Parsed Response'),
                        Tab(text: 'Raw Response'),
                      ],
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                    ),
                    SizedBox(
                      height: 200,
                      child: TabBarView(
                        children: [
                          // Prompt tab
                          SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lastPrompt.isEmpty ? 'No prompt available' : lastPrompt,
                                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                          ),
                          // Parsed JSON tab
                          SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lastParsedJson.isEmpty
                                    ? 'No parsed response available'
                                    : lastParsedJson,
                                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                          ),
                          // Raw response tab
                          SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lastRawResponse.isEmpty
                                    ? 'No raw response available'
                                    : lastRawResponse,
                                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Also show in UI for easier viewing
                        // Get.snackbar(
                        //   'API Response Printed',
                        //   'Full API response has been printed to the console',
                        //   snackPosition: SnackPosition.BOTTOM,
                        //   duration: const Duration(seconds: 3),
                        // );
                        Get.back(); // Close dialog
                      },
                      child: Text('Close'),
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

  // Build prompt with specific instructions for Gemini
  String _buildPrompt({
    String? category,
    int? minPlayers,
    int? maxPlayers,
    int? maxTimeMinutes,
    int gameCount = 5,
    int page = 1,
  }) {
    // If the category is Ice Breakers, ensure we get at least 5 games
    final effectiveGameCount =
        category?.toLowerCase().contains('ice breaker') == true
            ? Math.max(gameCount, 5)
            : gameCount;

    // Add randomness to ensure different responses each time
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSeed = DateTime.now().microsecondsSinceEpoch % 10000;

    String basePrompt = '''
    Generate a list of activity games in JSON format. 
    Make sure to create unique, varied, and different games than previous requests.
    Use randomization seed: $randomSeed and timestamp: $timestamp to ensure variety.
    
    Each game should include id, name, description, category, imageUrl, minPlayers, maxPlayers, estimatedTimeMinutes, 
    instructions (as array of strings), isFeatured, difficultyLevel, materialsRequired (as array of strings), 
    gameType, rating, isTimeBound, teamBased, rules (as array of strings), howToPlay, 
    winnerGamePlayerOrTeam (a detailed description of who wins the game), and
    outOfPlayRules (an array of 3-5 rules for when players are eliminated or out of the game).
    
    For each game:
    - The "winnerGamePlayerOrTeam" field should describe in 1-2 sentences who or which team wins the game and how.
    - The "outOfPlayRules" should be an array of 3-5 strings describing conditions when players are eliminated or out of play.
    - For the "imageUrl" field, you can just provide any short placeholder text. This will be replaced by the app.
    
    Generate creative and interesting games that are not commonly known or popular.
    Ensure high variety in the types of games, player counts, and durations.
    ''';

    // Add pagination information
    if (page > 1) {
      basePrompt +=
          '\n\nThis is page $page of results. Generate different games than those on previous pages.';
    }

    basePrompt += '''
    
    Return the response as a valid JSON array only, without any additional text, explanation, or markdown formatting.
    Do not include any text before or after the JSON array.
    ''';

    // Add filters to the prompt
    List<String> filters = [];

    if (category != null) {
      filters.add('The category must be "$category".');

      // For Ice Breakers, add specific instructions to ensure variety
      if (category.toLowerCase().contains('ice breaker')) {
        filters.add(
          'Ensure a diverse range of ice breaker games that would work well in different settings (office, social events, team building).',
        );
        filters.add('Include games with varying levels of interaction and engagement.');
      }
    }

    if (minPlayers != null) {
      filters.add(
        'The games must support at least $minPlayers players (minPlayers ≥ $minPlayers).',
      );
    }

    if (maxPlayers != null) {
      filters.add(
        'The games must not require more than $maxPlayers players (maxPlayers ≤ $maxPlayers).',
      );
    }

    if (maxTimeMinutes != null) {
      filters.add(
        'The games must not take longer than $maxTimeMinutes minutes (estimatedTimeMinutes ≤ $maxTimeMinutes).',
      );
    }

    if (filters.isNotEmpty) {
      basePrompt += '\n\nAdditional requirements:\n';
      for (var filter in filters) {
        basePrompt += '- $filter\n';
      }
    }

    // Explicitly request the number of games
    basePrompt += '\n\nProvide exactly $effectiveGameCount games in the response.\n';

    // Add emphasis for variety
    basePrompt +=
        '\nIMPORTANT: Make these games different from any previous responses. Create completely unique games not commonly known.';

    return basePrompt;
  }

  // Get a single random game
  Future<Game?> getRandomGame() async {
    try {
      // Fetching a single random game from Gemini
      final List<Game> games = await getGames(gameCount: 1, isRandom: true);
      return games.isNotEmpty ? games.first : null;
    } catch (e) {
      debugPrint('Error getting random game: $e');
      return null;
    }
  }

  // Function to get games based on filters
  Future<List<Game>> getGames({
    String? category,
    int? minPlayers,
    int? maxPlayers,
    int? maxTimeMinutes,
    int gameCount = 5,
    double temperature = 0.2,
    bool isRandom = false,
    int page = 1,
  }) async {
    try {
      // Get API key from secure storage
      final apiKey = await ApiConfig.getGeminiApiKey();

      // Check if API key is the default message
      if (apiKey.startsWith("PLEASE_ADD_YOUR_GEMINI_API_KEY")) {
        debugPrint('No API key set. Please add your Gemini API key in Settings.');
        Get.snackbar(
          'API Key Required',
          'Please add your Gemini API key in Settings to use this feature.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return [];
      }

      // Build prompt based on filters
      String prompt = _buildPrompt(
        category: category,
        minPlayers: minPlayers,
        maxPlayers: maxPlayers,
        maxTimeMinutes: maxTimeMinutes,
        gameCount: gameCount,
        page: page,
      );

      // Store the prompt for later reference
      lastPrompt = prompt;

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
          "temperature": temperature,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 8192,
          "responseMimeType": "application/json",
        },
      };

      // Make API request
      final response = await _dio.post(
        "$apiUrl?key=$apiKey",
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      // Store the raw response for debugging
      lastRawResponse = json.encode(response.data);

      // Print the prompt for debugging
      debugPrint('===== PROMPT TO GEMINI =====');
      debugPrint(prompt);
      debugPrint('===== END PROMPT =====');

      // Print raw response to console
      debugPrint('===== RAW API RESPONSE =====');
      debugPrint(lastRawResponse);
      debugPrint('===== END RAW RESPONSE =====');

      // Handle response
      if (response.statusCode == 200) {
        try {
          // Extract the JSON string from the response
          final textValue = response.data['candidates'][0]['content']['parts'][0]['text'];

          // Store the parsed JSON for debugging
          lastParsedJson = textValue;

          // Print parsed JSON
          debugPrint('===== PARSED JSON FROM GEMINI =====');
          debugPrint(textValue);
          debugPrint('===== END PARSED JSON =====');

          // Clean up the JSON string before parsing
          String cleanedJson = _cleanupJsonString(textValue);

          // Parse the JSON string to get the games list
          List<dynamic> gamesJson;
          try {
            gamesJson = json.decode(cleanedJson);
          } catch (decodeError) {
            debugPrint('Error decoding JSON, attempting to fix: $decodeError');

            // Try to extract valid JSON using regex if decoding fails
            final jsonArrayRegex = RegExp(r'\[.*\]', dotAll: true);
            final match = jsonArrayRegex.firstMatch(cleanedJson);

            if (match != null) {
              final extractedJson = match.group(0);
              debugPrint('Extracted JSON array: $extractedJson');
              try {
                gamesJson = json.decode(extractedJson!);
              } catch (e) {
                debugPrint('Still failed to parse JSON: $e');
                return [];
              }
            } else {
              debugPrint('Could not extract valid JSON array');
              return [];
            }
          }

          // Convert JSON to Game objects with error handling for each game
          final List<Game> games = [];
          for (var gameJson in gamesJson) {
            try {
              if (gameJson is Map<String, dynamic>) {
                final game = Game.fromJson(gameJson);
                games.add(game);
              }
            } catch (e) {
              debugPrint('Error parsing individual game: $e');
              // Continue with next game instead of failing
            }
          }

          // Process games to get Unsplash images
          final processedGames = await processGamesWithUnsplashImages(games);

          return processedGames;
        } catch (e) {
          debugPrint('Error parsing Gemini response: $e');
          Get.snackbar(
            'Error',
            'Failed to parse games data from the server. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return [];
        }
      } else {
        debugPrint('Error getting games: ${response.statusCode} - ${response.data}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception in getGames: $e');
      return [];
    }
  }

  // Get a specific game by ID
  Future<Game?> getGameDetails(String id) async {
    try {
      // Get API key from secure storage
      final apiKey = await ApiConfig.getGeminiApiKey();

      // Check if API key is the default message
      if (apiKey.startsWith("PLEASE_ADD_YOUR_GEMINI_API_KEY")) {
        debugPrint('No API key set. Please add your Gemini API key in Settings.');
        Get.snackbar(
          'API Key Required',
          'Please add your Gemini API key in Settings to use this feature.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return null;
      }

      String prompt = '''
      Generate detailed information for a game with ID "$id" in JSON format.
      The game should include id, name, description, category, imageUrl, minPlayers, maxPlayers, estimatedTimeMinutes, 
      instructions (as array of strings), isFeatured, difficultyLevel, materialsRequired (as array of strings), 
      gameType, rating, isTimeBound, teamBased, rules (as array of strings), a detailed howToPlay explanation,
      winnerGamePlayerOrTeam (a detailed description of who wins the game), and
      outOfPlayRules (an array of 3-5 rules for when players are eliminated or out of the game).
      
      The "winnerGamePlayerOrTeam" field should describe in 1-2 sentences who or which team wins the game and how.
      The "outOfPlayRules" should be an array of 3-5 strings describing conditions when players are eliminated or out of play.
      For the "imageUrl" field, you can just provide any short placeholder text. This will be replaced by the app.
      
      Return the response as a valid JSON object only, without any additional text, explanation, or markdown formatting.
      Do not include any text before or after the JSON object.
      ''';

      // Store the prompt for later reference
      lastPrompt = prompt;

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

      final response = await _dio.post(
        "$apiUrl?key=$apiKey",
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      // Store the raw response for debugging
      lastRawResponse = json.encode(response.data);

      // Print the prompt for debugging
      debugPrint('===== PROMPT TO GEMINI =====');
      debugPrint(prompt);
      debugPrint('===== END PROMPT =====');
      // Print raw response to console
      debugPrint('===== RAW API RESPONSE =====');
      debugPrint(lastRawResponse);
      debugPrint('===== END RAW RESPONSE =====');

      if (response.statusCode == 200) {
        try {
          final textValue = response.data['candidates'][0]['content']['parts'][0]['text'];

          // Store the parsed JSON for debugging
          lastParsedJson = textValue;

          // Print parsed JSON
          debugPrint('===== PARSED JSON FROM GEMINI =====');
          debugPrint(textValue);
          debugPrint('===== END PARSED JSON =====');

          // Clean up the JSON string before parsing
          String cleanedJson = _cleanupJsonString(textValue);

          // Parse the JSON string to get the game details
          Map<String, dynamic> gameJson;
          try {
            final decoded = json.decode(cleanedJson);

            // Handle if the result is a list instead of a map
            if (decoded is List && decoded.isNotEmpty) {
              gameJson = decoded.first;
            } else if (decoded is Map<String, dynamic>) {
              gameJson = decoded;
            } else {
              debugPrint('Unexpected decoded JSON type: ${decoded.runtimeType}');
              return null;
            }
          } catch (decodeError) {
            debugPrint('Error decoding JSON, attempting to fix: $decodeError');

            // Try to extract valid JSON using regex if decoding fails
            final jsonObjectRegex = RegExp(r'\{.*\}', dotAll: true);
            final match = jsonObjectRegex.firstMatch(cleanedJson);

            if (match != null) {
              final extractedJson = match.group(0);
              debugPrint('Extracted JSON object: $extractedJson');
              try {
                gameJson = json.decode(extractedJson!) as Map<String, dynamic>;
              } catch (e) {
                debugPrint('Still failed to parse JSON: $e');
                return null;
              }
            } else {
              debugPrint('Could not extract valid JSON object');
              return null;
            }
          }

          // Create Game object from JSON
          final game = Game.fromJson(gameJson);

          // Process game to get Unsplash image
          final processedGame = await processGameWithUnsplashImage(game);

          return processedGame;
        } catch (e) {
          debugPrint('Error parsing Gemini response for game details: $e');
          Get.snackbar(
            'Error',
            'Failed to get game details. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return null;
        }
      } else {
        debugPrint('Error getting game details: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in getGameDetails: $e');
      return null;
    }
  }

  // Get search suggestions based on a query string
  Future<List<String>> getSuggestions(String query) async {
    try {
      // Get API key from secure storage
      final apiKey = await ApiConfig.getGeminiApiKey();

      if (apiKey.startsWith("PLEASE_ADD_YOUR_GEMINI_API_KEY")) {
        debugPrint('No API key set. Please add your Gemini API key in Settings.');
        return [];
      }

      // Check if the query contains category context (e.g., "Ice Breakers related to...")
      bool hasCategoryContext = query.contains("related to");
      String category = "";
      String searchTerm = query;

      if (hasCategoryContext) {
        // Extract category and search term
        final parts = query.split("related to");
        if (parts.length >= 2) {
          category = parts[0].trim();
          searchTerm = parts[1].trim();
        }
      }

      // Create a prompt for search suggestions
      String prompt = '''
You are a search suggestion engine for an activity games app. ${hasCategoryContext ? 'The user is currently viewing the "$category" category.' : ''}
Given the partial search query "$searchTerm" provided by the user, suggest relevant search terms or activities${hasCategoryContext ? ' related to $category' : ''}.
Return ONLY an array of strings with relevant search suggestions. Limit to a maximum of 6 suggestions.

User query: "$searchTerm"

Return format: 
["suggestion1", "suggestion2", ...]

Remember to ONLY return the JSON array, nothing else.
''';

      // Store the prompt for later reference
      lastPrompt = prompt;

      // Prepare request body with lower temperature for more focused results
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
          "maxOutputTokens": 2048,
          "responseMimeType": "application/json",
        },
      };

      // Make API request
      final response = await _dio.post(
        "$apiUrl?key=$apiKey",
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      // Store the raw response for debugging
      lastRawResponse = json.encode(response.data);

      // Handle API response
      if (response.statusCode == 200) {
        String generatedText = "";

        try {
          // Extract the text from the response
          generatedText = response.data["candidates"][0]["content"]["parts"][0]["text"];

          // Clean up the text to ensure it's proper JSON
          generatedText = generatedText.trim();

          // If response is not wrapped in array brackets, do it
          if (!generatedText.startsWith("[")) {
            generatedText = "[$generatedText]";
          }

          // Parse the JSON
          final List<dynamic> parsedJson = json.decode(generatedText);
          lastParsedJson = json.encode(parsedJson); // Store for debugging

          // Convert each item to string and return
          return parsedJson.map((item) => item.toString()).toList();
        } catch (e) {
          debugPrint('Error parsing suggestions response: $e');
          debugPrint('Response was: $generatedText');
          return [];
        }
      } else {
        debugPrint('Error getting suggestions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception getting suggestions: $e');
      return [];
    }
  }

  // Process game data to fetch and set Unsplash images
  Future<List<Game>> processGamesWithUnsplashImages(List<Game> games) async {
    // Don't fetch Unsplash images, just use app logo as placeholder
    List<Game> processedGames = [];

    for (var game in games) {
      // Create a new game with the updated imageUrl pointing to app logo
      final updatedGame = Game(
        id: game.id,
        name: game.name,
        description: game.description,
        category: game.category,
        imageUrl: 'assets/icons/app_logo.svg', // Use app logo as placeholder
        minPlayers: game.minPlayers,
        maxPlayers: game.maxPlayers,
        estimatedTimeMinutes: game.estimatedTimeMinutes,
        instructions: game.instructions,
        isFeatured: game.isFeatured,
        difficultyLevel: game.difficultyLevel,
        materialsRequired: game.materialsRequired,
        gameType: game.gameType,
        rating: game.rating,
        isTimeBound: game.isTimeBound,
        teamBased: game.teamBased,
        rules: game.rules,
        howToPlay: game.howToPlay,
        winnerGamePlayerOrTeam: game.winnerGamePlayerOrTeam,
        outOfPlayRules: game.outOfPlayRules,
      );

      processedGames.add(updatedGame);
    }

    return processedGames;
  }

  // Process a single game with Unsplash images
  Future<Game?> processGameWithUnsplashImage(Game? game) async {
    if (game == null) return null;

    // Don't fetch from Unsplash, use app logo instead
    return Game(
      id: game.id,
      name: game.name,
      description: game.description,
      category: game.category,
      imageUrl: 'assets/icons/app_logo.svg', // Use app logo as placeholder
      minPlayers: game.minPlayers,
      maxPlayers: game.maxPlayers,
      estimatedTimeMinutes: game.estimatedTimeMinutes,
      instructions: game.instructions,
      isFeatured: game.isFeatured,
      difficultyLevel: game.difficultyLevel,
      materialsRequired: game.materialsRequired,
      gameType: game.gameType,
      rating: game.rating,
      isTimeBound: game.isTimeBound,
      teamBased: game.teamBased,
      rules: game.rules,
      howToPlay: game.howToPlay,
      winnerGamePlayerOrTeam: game.winnerGamePlayerOrTeam,
      outOfPlayRules: game.outOfPlayRules,
    );
  }

  // Add a new method to get out of play rules from Gemini for a specific game
  Future<List<String>> getOutOfPlayRules(Game game) async {
    try {
      // Build a prompt to get out of play rules for the game
      final prompt = """
Generate a list of 4-6 "Out of Play Rules" for the game "${game.name}". 
These rules indicate when a player is out of the game or cannot continue playing.

Game Description: ${game.description}
Game Type: ${game.gameType}
Difficulty: ${game.difficultyLevel}
Number of Players: ${game.minPlayers} - ${game.maxPlayers}

Return only a JSON array of strings in the following format:
["Rule 1", "Rule 2", "Rule 3", ...]

Each rule should:
- Be clear and specific
- Focus on conditions that eliminate a player
- Be relevant to the game type and mechanics
- Be appropriate for the difficulty level
- Be easy to understand and enforce

Example format:
["Player steps outside the boundary", "Player breaks any main rule twice", "Player fails to complete their turn within 20 seconds"]
""";

      lastPrompt = prompt;

      // Get API key
      final apiKey = await ApiConfig.getGeminiApiKey();

      // Check if API key is valid
      if (apiKey.startsWith("PLEASE_ADD_YOUR_GEMINI_API_KEY")) {
        debugPrint("Please add your Gemini API key to api_config.dart");
        return [];
      }

      // Prepare headers and data
      final headers = {'Content-Type': 'application/json'};
      final data = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.4,
          "topK": 32,
          "topP": 0.8,
          "maxOutputTokens": 800,
          "responseMimeType": "application/json",
          "responseSchema": {
            "type": "array",
            "items": {"type": "string"},
          },
        },
        "safetySettings": [
          {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
          {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
          {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
          {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
        ],
      };

      // Add API key and make the API call
      final response = await _dio.post(
        "$apiUrl?key=$apiKey",
        data: data,
        options: Options(headers: headers),
      );

      lastRawResponse = jsonEncode(response.data);

      // Extract the outOfPlayRules array from the JSON response
      final candidates = response.data['candidates'] as List<dynamic>;

      if (candidates.isEmpty) {
        return [];
      }

      final content = candidates.first['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;

      if (parts.isEmpty) {
        return [];
      }

      // Extract the JSON array from the text response
      final jsonText = parts.first['text'] as String;

      // Sometimes Gemini returns markdown with code blocks or extra text
      final jsonRegExp = RegExp(r'\[.*?\]', dotAll: true);
      final match = jsonRegExp.firstMatch(jsonText);

      if (match == null) {
        return [];
      }

      final jsonArray = match.group(0);
      lastParsedJson = jsonArray ?? '';

      // Parse the JSON array
      final List<dynamic> outOfPlayRulesList = jsonDecode(jsonArray!);

      // Convert to List<String>
      return outOfPlayRulesList.map((rule) => rule.toString()).toList();
    } catch (e) {
      debugPrint('Error getting out of play rules: $e');
      return [];
    }
  }

  // Add a new method to get winner and eliminated player information from Gemini for a specific game
  Future<Map<String, String>> getGameWinnerInfo(Game game) async {
    try {
      // Build a prompt to get winner and eliminated player information for the game
      final prompt = """
Generate winner and eliminated player information for the game "${game.name}".
Based on the game description and rules, identify:
1. The winner condition - who or which team wins the game
2. Elimination condition - when players get eliminated or out of play

Game Description: ${game.description}
Game Type: ${game.gameType}
Difficulty: ${game.difficultyLevel}
Number of Players: ${game.minPlayers} - ${game.maxPlayers}
Game Rules: ${game.rules.join('. ')}

Return the results as a JSON object with the following structure:
{
  "winner": "Description of who/what team wins and how",
  "eliminated": "Description of how players get eliminated"
}

The descriptions should be:
- Clear and specific
- Based on the game's rules and mechanics
- Relevant to the game type
- Easy to understand
- 1-2 sentences in length
""";

      lastPrompt = prompt;

      // Get API key
      final apiKey = await ApiConfig.getGeminiApiKey();

      // Check if API key is valid
      if (apiKey.startsWith("PLEASE_ADD_YOUR_GEMINI_API_KEY")) {
        debugPrint("Please add your Gemini API key to api_config.dart");
        return {
          "winner": "The player or team that completes the objective first.",
          "eliminated": "Players who break the game rules or fail to meet objectives.",
        };
      }

      // Prepare headers and data
      final headers = {'Content-Type': 'application/json'};
      final data = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.3,
          "topK": 32,
          "topP": 0.8,
          "maxOutputTokens": 800,
          "responseMimeType": "application/json",
        },
        "safetySettings": [
          {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
          {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
          {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
          {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
        ],
      };

      // Add API key and make the API call
      final response = await _dio.post(
        "$apiUrl?key=$apiKey",
        data: data,
        options: Options(headers: headers),
      );

      lastRawResponse = jsonEncode(response.data);

      // Extract the response from Gemini
      final candidates = response.data['candidates'] as List<dynamic>;

      if (candidates.isEmpty) {
        return {
          "winner": "The player or team that completes the objective first.",
          "eliminated": "Players who break the game rules or fail to meet objectives.",
        };
      }

      final content = candidates.first['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;

      if (parts.isEmpty) {
        return {
          "winner": "The player or team that completes the objective first.",
          "eliminated": "Players who break the game rules or fail to meet objectives.",
        };
      }

      // Extract the JSON from the text response
      final jsonText = parts.first['text'] as String;

      // Sometimes Gemini returns markdown with code blocks or extra text
      final jsonRegExp = RegExp(r'\{.*?\}', dotAll: true);
      final match = jsonRegExp.firstMatch(jsonText);

      if (match == null) {
        return {
          "winner": "The player or team that completes the objective first.",
          "eliminated": "Players who break the game rules or fail to meet objectives.",
        };
      }

      final jsonObject = match.group(0);
      lastParsedJson = jsonObject ?? '';

      // Parse the JSON object
      final Map<String, dynamic> gameInfo = jsonDecode(jsonObject!);

      // Return the winner and eliminated information
      return {
        "winner":
            gameInfo['winner'] as String? ??
            "The player or team that completes the objective first.",
        "eliminated":
            gameInfo['eliminated'] as String? ??
            "Players who break the game rules or fail to meet objectives.",
      };
    } catch (e) {
      debugPrint('Error getting game winner info: $e');
      return {
        "winner": "The player or team that completes the objective first.",
        "eliminated": "Players who break the game rules or fail to meet objectives.",
      };
    }
  }

  // Helper method to clean up JSON strings that might be malformed
  String _cleanupJsonString(String jsonString) {
    String cleaned = jsonString.trim();

    // Remove any markdown code block delimiters
    cleaned = cleaned.replaceAll('```json', '');
    cleaned = cleaned.replaceAll('```', '');

    // Remove common prefixes that Gemini might add
    final prefixes = [
      "Here's the JSON:",
      "Here is the JSON:",
      "The following is",
      "Here are the games:",
    ];

    for (final prefix in prefixes) {
      if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
        cleaned = cleaned.substring(prefix.length).trim();
      }
    }

    // Check if we're missing array brackets for games list
    if (!cleaned.startsWith('[') && cleaned.contains('{')) {
      // If no opening bracket but has objects, likely we need to add brackets
      if (cleaned.startsWith('{')) {
        cleaned = '[$cleaned]';
      }
    }

    // Clean up trailing commas which can cause JSON parse errors
    cleaned = cleaned.replaceAll(',}', '}');
    cleaned = cleaned.replaceAll(',]', ']');

    return cleaned;
  }
}
