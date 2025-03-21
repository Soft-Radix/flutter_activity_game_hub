import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  // Secure storage instance
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Key for storing the Gemini API key
  static const String _geminiApiKeyStorageKey = 'gemini_api_key';

  // Default API key if not set in secure storage
  // Replace this with your actual Gemini API key for testing
  static const String _defaultGeminiApiKey = "PLEASE_ADD_YOUR_GEMINI_API_KEY_IN_SETTINGS";

  // Get the API key (first from secure storage, then default)
  static Future<String> getGeminiApiKey() async {
    String? storedApiKey = await _secureStorage.read(key: _geminiApiKeyStorageKey);
    return storedApiKey ?? _defaultGeminiApiKey;
  }

  // Set the API key in secure storage
  static Future<void> setGeminiApiKey(String apiKey) async {
    await _secureStorage.write(key: _geminiApiKeyStorageKey, value: apiKey);
  }
}
