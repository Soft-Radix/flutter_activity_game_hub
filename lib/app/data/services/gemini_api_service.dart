import 'dart:convert';

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
                        Get.snackbar(
                          'API Response Printed',
                          'Full API response has been printed to the console',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 3),
                        );
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
    // Add randomness to ensure different responses each time
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSeed = DateTime.now().microsecondsSinceEpoch % 10000;

    String basePrompt = '''
    Generate a list of activity games in JSON format. 
    Make sure to create unique, varied, and different games than previous requests.
    Use randomization seed: $randomSeed and timestamp: $timestamp to ensure variety.
    
    Each game should include id, name, description, category, imageUrl, minPlayers, maxPlayers, estimatedTimeMinutes, 
    instructions (as array of strings), isFeatured, difficultyLevel, materialsRequired (as array of strings), 
    gameType, rating, isTimeBound, teamBased, rules (as array of strings), and howToPlay.
    
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

    basePrompt += '\n\nProvide exactly $gameCount games in the response.';

    // Add a request for novelty to avoid repetition
    basePrompt +=
        '\n\nIMPORTANT: Make these games different from any previous responses. Create completely unique games not commonly known.';

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

          // Parse the JSON string to get the games list
          final List<dynamic> gamesJson = json.decode(textValue);

          // Process games to ensure proper imageUrl values
          for (var game in gamesJson) {
            // If imageUrl is a URL but doesn't start with http/https, add https://
            if (game['imageUrl'] != null &&
                game['imageUrl'].toString().isNotEmpty &&
                !game['imageUrl'].toString().startsWith('assets/') &&
                !game['imageUrl'].toString().startsWith('http')) {
              game['imageUrl'] = 'https://${game['imageUrl']}';
            }
            // If imageUrl is empty or null, use a placeholder
            else if (game['imageUrl'] == null || game['imageUrl'].toString().isEmpty) {
              game['imageUrl'] = 'assets/images/placeholder.svg';
            }
          }

          // Show a notification that API response is available
          Get.snackbar(
            'API Response Available',
            'Check the console for the full API response',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          return gamesJson.map((game) => Game.fromJson(game)).toList();
        } catch (e) {
          debugPrint('Error parsing Gemini response: $e');
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
      gameType, rating, isTimeBound, teamBased, rules (as array of strings), and a detailed howToPlay explanation.
      
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

          final Map<String, dynamic> gameJson = json.decode(textValue);

          // Process imageUrl to ensure proper formatting
          if (gameJson['imageUrl'] != null &&
              gameJson['imageUrl'].toString().isNotEmpty &&
              !gameJson['imageUrl'].toString().startsWith('assets/') &&
              !gameJson['imageUrl'].toString().startsWith('http')) {
            gameJson['imageUrl'] = 'https://${gameJson['imageUrl']}';
          }
          // If imageUrl is empty or null, use a placeholder
          else if (gameJson['imageUrl'] == null || gameJson['imageUrl'].toString().isEmpty) {
            gameJson['imageUrl'] = 'assets/images/placeholder.svg';
          }

          // Show a notification that API response is available
          Get.snackbar(
            'API Response Available',
            'Check the console for the full API response',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          return Game.fromJson(gameJson);
        } catch (e) {
          debugPrint('Error parsing Gemini response for game details: $e');
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
}
