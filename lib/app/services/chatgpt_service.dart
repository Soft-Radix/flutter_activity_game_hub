import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ChatGptService extends GetxService {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  // Note: In a real app, you should use environment variables or secure storage for API keys
  late String _apiKey;

  Future<ChatGptService> init({String? apiKey}) async {
    _apiKey = apiKey ?? '';
    return this;
  }

  // Set API key
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  // Get game suggestion from ChatGPT
  Future<String> getGameSuggestion({
    int? numberOfPlayers,
    int? availableTimeMinutes,
    String? preferredCategory,
    String? additionalPreferences,
  }) async {
    if (_apiKey.isEmpty) {
      return 'Please set your OpenAI API key in the settings to get game suggestions.';
    }

    try {
      // Construct the prompt based on provided parameters
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
          '. Include the name of the game, a brief description, and some simple instructions.';

      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey', 'Content-Type': 'application/json'},
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that suggests fun office team-building games.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final suggestion = data['choices'][0]['message']['content'];
        return suggestion;
      } else {
        return 'Failed to get game suggestion. Please try again later.';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Method to get the game of the day suggestion
  Future<String> getGameOfTheDay() async {
    return getGameSuggestion(
      additionalPreferences:
          'Make this a featured game of the day that is appropriate for a diverse office environment',
    );
  }
}
