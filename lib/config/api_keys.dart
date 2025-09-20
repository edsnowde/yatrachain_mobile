class ApiKeys {
  // Google Maps API Key
  static const String googleMapsApiKey =
      'enter your google maps key';

  // Gemini AI API Key
  static const String geminiApiKey = 'enter your gemini key';

  // Instructions for getting API keys:

  // Google Maps API Key:
  // 1. Go to Google Cloud Console (https://console.cloud.google.com/)
  // 2. Create a new project or select existing one
  // 3. Enable Maps SDK for Android and iOS
  // 4. Go to Credentials and create API key
  // 5. Restrict the API key to your app's package name
  // 6. Replace 'YOUR_GOOGLE_MAPS_API_KEY' with your actual key

  // Gemini AI API Key:
  // 1. Go to Google AI Studio (https://aistudio.google.com/)
  // 2. Sign in with your Google account
  // 3. Click "Get API key" in the left sidebar
  // 4. Create a new API key
  // 5. Copy the key and replace 'YOUR_GEMINI_API_KEY' with your actual key

  // Security Note:
  // In production, store these keys securely using:
  // - Environment variables
  // - Secure storage
  // - Remote configuration
  // Never commit API keys to version control!
}
