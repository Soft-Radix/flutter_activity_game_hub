import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../data/models/chatgpt_suggestion_model.dart';
import '../data/providers/chatgpt_provider.dart';

class ChatGptService extends GetxService {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final storage = const FlutterSecureStorage();
  final ChatGptProvider _chatGptProvider = Get.find<ChatGptProvider>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString apiKey = ''.obs;
  final RxBool hasApiKey = false.obs;

  // Initialize the service
  Future<ChatGptService> init({String? apiKey}) async {
    // Load the API key from secure storage
    final savedApiKey = await storage.read(key: 'openai_api_key');
    if (savedApiKey != null && savedApiKey.isNotEmpty) {
      this.apiKey.value = savedApiKey;
      hasApiKey.value = true;
    } else if (apiKey != null && apiKey.isNotEmpty) {
      this.apiKey.value = apiKey;
      hasApiKey.value = true;
      await storage.write(key: 'openai_api_key', value: apiKey);
    }

    return this;
  }

  // Set and save API key
  Future<void> setApiKey(String apiKey) async {
    this.apiKey.value = apiKey;
    hasApiKey.value = apiKey.isNotEmpty;

    // Save to secure storage
    if (apiKey.isNotEmpty) {
      await storage.write(key: 'openai_api_key', value: apiKey);
    } else {
      await storage.delete(key: 'openai_api_key');
    }
  }

  // Get a game suggestion from ChatGPT and save it to local storage
  Future<ChatGptSuggestion> getGameSuggestion({
    int? numberOfPlayers,
    int? availableTimeMinutes,
    String? preferredCategory,
    String? additionalPreferences,
  }) async {
    isLoading.value = true;

    try {
      // First, check if we need to use cached data
      if (apiKey.value.isEmpty) {
        // Try to get the most recent suggestion from storage
        final cachedSuggestion = _chatGptProvider.getMostRecentSuggestionByType(
          SuggestionType.gameSuggestion,
        );

        if (cachedSuggestion != null) {
          isLoading.value = false;
          return cachedSuggestion;
        }

        // If no cached suggestion, return an error message
        final errorSuggestion = ChatGptSuggestion.fromResponse(
          id: _chatGptProvider.generateSuggestionId(),
          content: 'Please set your OpenAI API key in the settings to get game suggestions.',
          type: SuggestionType.gameSuggestion,
        );

        await _chatGptProvider.saveSuggestion(errorSuggestion);
        isLoading.value = false;
        return errorSuggestion;
      }

      // Construct parameters for the API call
      Map<String, dynamic> params = {};
      if (numberOfPlayers != null) params['numberOfPlayers'] = numberOfPlayers;
      if (availableTimeMinutes != null) params['availableTimeMinutes'] = availableTimeMinutes;
      if (preferredCategory != null) params['preferredCategory'] = preferredCategory;
      if (additionalPreferences != null) params['additionalPreferences'] = additionalPreferences;

      // Construct the prompt
      String prompt = 'Suggest a fun office team-building game';

      if (numberOfPlayers != null) {
        prompt += ' for $numberOfPlayers players';
      }

      if (availableTimeMinutes != null) {
        prompt += ' that takes about $availableTimeMinutes minutes';
      }

      if (preferredCategory != null && preferredCategory.isNotEmpty) {
        prompt += ' in the $preferredCategory category';
      }

      if (additionalPreferences != null && additionalPreferences.isNotEmpty) {
        prompt += '. Additional preferences: $additionalPreferences';
      }

      prompt +=
          '. Format the response with the following sections: Game Name, Description, Instructions (as a numbered list).';

      // Make API call with error handling
      final response = await _makeApiCall(
        prompt: prompt,
        systemRole: 'You are a helpful assistant that suggests fun office team-building games.',
      );

      // Create and save the suggestion
      final suggestion = ChatGptSuggestion.fromResponse(
        id: _chatGptProvider.generateSuggestionId(),
        content: response,
        type: SuggestionType.gameSuggestion,
        parameters: params,
      );

      await _chatGptProvider.saveSuggestion(suggestion);

      isLoading.value = false;
      return suggestion;
    } catch (e) {
      // Handle errors and provide a fallback response
      final errorSuggestion = ChatGptSuggestion.fromResponse(
        id: _chatGptProvider.generateSuggestionId(),
        content: 'Error getting suggestion: ${e.toString()}\n\nPlease try again later.',
        type: SuggestionType.gameSuggestion,
      );

      await _chatGptProvider.saveSuggestion(errorSuggestion);
      isLoading.value = false;
      return errorSuggestion;
    }
  }

  // Get game of the day
  Future<ChatGptSuggestion> getGameOfTheDay() async {
    try {
      // Check for cached game of the day - use if less than 24 hours old
      final cachedGame = _chatGptProvider.getMostRecentSuggestionByType(
        SuggestionType.gameOfTheDay,
      );

      if (cachedGame != null) {
        final now = DateTime.now();
        final diff = now.difference(cachedGame.timestamp);

        // If less than 24 hours old, use the cached version
        if (diff.inHours < 24) {
          return cachedGame;
        }
      }

      // Get a new suggestion
      final suggestion = await getGameSuggestion(
        additionalPreferences:
            'Make this a featured game of the day that is appropriate for a diverse office environment',
      );

      // Create a new game of the day entry
      final gameOfTheDay = ChatGptSuggestion.fromResponse(
        id: _chatGptProvider.generateSuggestionId(),
        content: suggestion.content,
        type: SuggestionType.gameOfTheDay,
      );

      await _chatGptProvider.saveSuggestion(gameOfTheDay);
      return gameOfTheDay;
    } catch (e) {
      // If error, try to use cached version regardless of age
      final cachedGame = _chatGptProvider.getMostRecentSuggestionByType(
        SuggestionType.gameOfTheDay,
      );

      if (cachedGame != null) {
        return cachedGame;
      }

      // Create an error suggestion
      final errorSuggestion = ChatGptSuggestion.fromResponse(
        id: _chatGptProvider.generateSuggestionId(),
        content: 'Error getting game of the day. Please try again later.',
        type: SuggestionType.gameOfTheDay,
      );

      await _chatGptProvider.saveSuggestion(errorSuggestion);
      return errorSuggestion;
    }
  }

  // Get all saved suggestions of a specific type
  List<ChatGptSuggestion> getAllSavedSuggestions(SuggestionType type) {
    return _chatGptProvider.getAllSuggestionsByType(type);
  }

  // Make a generic API call to ChatGPT
  Future<String> _makeApiCall({
    required String prompt,
    String systemRole = 'You are a helpful assistant.',
    int maxTokens = 500,
    double temperature = 0.7,
  }) async {
    try {
      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer ${apiKey.value}', 'Content-Type': 'application/json'},
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemRole},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': maxTokens,
          'temperature': temperature,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final suggestion = data['choices'][0]['message']['content'];
        return suggestion;
      } else {
        return 'Failed to get response. Status code: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return 'API Error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      } else {
        return 'Connection Error: ${e.message}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Custom query to ChatGPT - allows user to ask any questions
  Future<ChatGptSuggestion> customQuery(String query) async {
    isLoading.value = true;

    try {
      if (apiKey.value.isEmpty) {
        final errorSuggestion = ChatGptSuggestion.fromResponse(
          id: _chatGptProvider.generateSuggestionId(),
          content: 'Please set your OpenAI API key in the settings to use this feature.',
          type: SuggestionType.customQuery,
        );

        await _chatGptProvider.saveSuggestion(errorSuggestion);
        isLoading.value = false;
        return errorSuggestion;
      }

      final response = await _makeApiCall(
        prompt: query,
        systemRole:
            'You are a helpful assistant that provides information about team-building activities and games.',
        maxTokens: 800,
      );

      final suggestion = ChatGptSuggestion.fromResponse(
        id: _chatGptProvider.generateSuggestionId(),
        content: response,
        type: SuggestionType.customQuery,
        parameters: {'query': query},
      );

      await _chatGptProvider.saveSuggestion(suggestion);

      isLoading.value = false;
      return suggestion;
    } catch (e) {
      final errorSuggestion = ChatGptSuggestion.fromResponse(
        id: _chatGptProvider.generateSuggestionId(),
        content: 'Error processing your query: ${e.toString()}\n\nPlease try again later.',
        type: SuggestionType.customQuery,
        parameters: {'query': query},
      );

      await _chatGptProvider.saveSuggestion(errorSuggestion);
      isLoading.value = false;
      return errorSuggestion;
    }
  }
}
