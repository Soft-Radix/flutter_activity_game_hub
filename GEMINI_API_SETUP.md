# Gemini API Integration Setup

This application uses Google's Gemini API to fetch game data. Follow these instructions to set up the API key and use the Gemini-powered features.

## Getting a Gemini API Key

1. Go to the Google AI Studio website: [https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click on "Create API Key"
4. Copy your API key for use in the application

## Setting Up the Application

### Option 1: Edit the API Config (Development)

1. Open the file `lib/app/data/services/api_config.dart`
2. Replace the value of `_defaultGeminiApiKey` with your API key:
   ```dart
   static const String _defaultGeminiApiKey = "YOUR_GEMINI_API_KEY";
   ```

### Option 2: Set the API Key in the App (Production)

The app includes a feature to set the API key securely at runtime:

1. Launch the app
2. Navigate to the Settings screen
3. Find the "API Settings" section
4. Enter your Gemini API key in the provided field and save

## Using Gemini-Powered Features

The application includes a GeminiAppController that uses the Gemini API to fetch and filter games. The following features are available:

- **Get All Games**: Fetches a list of games from the Gemini API
- **Get Games by Category**: Filters games by a specific category
- **Get Games by Player Count**: Filters games by the number of players
- **Get Games by Maximum Time**: Filters games by the maximum time duration
- **Combination Filters**: Apply multiple filters simultaneously

## Switching Between Dummy Data and Gemini API

The application includes both the original `GameProvider` with dummy data and the new `GeminiGameProvider` with API integration. You can switch between them in your controllers by changing:

```dart
// Using dummy data
final GameProvider _gameProvider = Get.find<GameProvider>();

// Using Gemini API
final GeminiGameProvider _gameProvider = Get.find<GeminiGameProvider>();
```

## Troubleshooting

If you encounter issues with the Gemini API:

1. **API Key Issues**: Ensure your API key is correct and has not expired
2. **Rate Limiting**: Gemini API has usage limits. If you exceed them, you may see errors
3. **Network Issues**: Check your internet connection
4. **Response Format**: The API is designed to request JSON responses from Gemini, but occasionally it may return non-compliant formats

## Security Notes

- The API key is stored securely using Flutter Secure Storage
- Never commit your API key to version control
- For production deployment, consider using environment variables or a secure backend service to manage API keys 