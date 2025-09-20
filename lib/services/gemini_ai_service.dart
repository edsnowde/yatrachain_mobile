import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:yatrachain/models/chat_message.dart';
import 'package:yatrachain/config/api_keys.dart';

class GeminiAIService {
  static const String _apiKey = ApiKeys.geminiApiKey;
  static late GenerativeModel _model;
  static bool _initialized = false;

  // Initialize Gemini AI
  static Future<void> initialize() async {
    if (!_initialized) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
      _initialized = true;
    }
  }

  // Get AI response for travel-related queries
  static Future<ChatMessage> getAIResponse(
    String userMessage, {
    List<ChatMessage>? chatHistory,
    Map<String, dynamic>? userContext,
  }) async {
    await initialize();

    try {
      final context = _buildContext(userContext);
      final history = _buildHistory(chatHistory);

      final prompt = '''
$context

$history

User: $userMessage

Please respond as YatraBot, a helpful AI travel assistant for Kerala. 
Provide accurate, helpful information about:
- Route suggestions and directions
- Transportation options (bus, metro, auto, etc.)
- Fare estimates and cost comparisons
- Traffic conditions and travel times
- Weather information for travel
- Local attractions and places to visit
- Travel tips and recommendations

Keep responses concise, friendly, and informative. Use Malayalam words where appropriate.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final aiResponse = response.text ??
          'Sorry, I couldn\'t process your request. Please try again.';

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: aiResponse,
        isBot: true,
        timestamp: DateTime.now(),
        quickReplies: _generateQuickReplies(userMessage),
        confidence: 0.9,
      );
    } catch (e) {
      print('Error getting AI response: $e');
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message:
            'Sorry, I\'m having trouble connecting right now. Please try again later.',
        isBot: true,
        timestamp: DateTime.now(),
        quickReplies: ['Try again', 'Help', 'Routes'],
      );
    }
  }

  // Build context for the AI
  static String _buildContext(Map<String, dynamic>? userContext) {
    if (userContext == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('User Context:');

    if (userContext['currentLocation'] != null) {
      buffer.writeln('- Current Location: ${userContext['currentLocation']}');
    }
    if (userContext['recentTrips'] != null) {
      buffer.writeln('- Recent Trips: ${userContext['recentTrips']}');
    }
    if (userContext['preferredTransport'] != null) {
      buffer.writeln(
          '- Preferred Transport: ${userContext['preferredTransport']}');
    }
    if (userContext['budget'] != null) {
      buffer.writeln('- Budget: ₹${userContext['budget']}');
    }

    return buffer.toString();
  }

  // Build chat history for context
  static String _buildHistory(List<ChatMessage>? chatHistory) {
    if (chatHistory == null || chatHistory.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('Recent Conversation:');

    final recentMessages = chatHistory.take(5).toList();
    for (final message in recentMessages) {
      final sender = message.isBot ? 'YatraBot' : 'User';
      buffer.writeln('$sender: ${message.message}');
    }

    return buffer.toString();
  }

  // Generate quick replies based on user message
  static List<String> _generateQuickReplies(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('route') || message.contains('direction')) {
      return ['Show on map', 'Alternative routes', 'Public transport'];
    } else if (message.contains('fare') || message.contains('cost')) {
      return ['Compare options', 'Budget travel', 'Premium options'];
    } else if (message.contains('traffic') || message.contains('time')) {
      return ['Live updates', 'Best time to travel', 'Avoid traffic'];
    } else if (message.contains('weather')) {
      return ['Current weather', 'Forecast', 'Travel conditions'];
    } else if (message.contains('place') || message.contains('visit')) {
      return ['Nearby attractions', 'Popular spots', 'Hidden gems'];
    } else {
      return ['More help', 'Routes', 'Fares', 'Traffic'];
    }
  }

  // Get route suggestions with AI insights
  static Future<Map<String, dynamic>> getRouteInsights(
    String from,
    String to,
    String transportMode,
  ) async {
    await initialize();

    try {
      final prompt = '''
Analyze the route from $from to $to using $transportMode in Kerala.
Provide insights on:
1. Best time to travel
2. Potential delays or issues
3. Alternative routes
4. Cost estimates
5. Travel tips
6. Local attractions along the way

Format as JSON with keys: bestTime, delays, alternatives, costEstimate, tips, attractions.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return {
        'bestTime': 'Morning 7-9 AM or Evening 6-8 PM',
        'delays': 'Possible traffic near city centers',
        'alternatives': 'Metro available for part of route',
        'costEstimate': '₹25-50 depending on mode',
        'tips': 'Carry water, check weather',
        'attractions': 'Local markets, temples',
        'aiInsights': response.text ?? 'No specific insights available',
      };
    } catch (e) {
      print('Error getting route insights: $e');
      return {
        'error': 'Unable to get AI insights',
        'fallback': true,
      };
    }
  }

  // Get personalized travel recommendations
  static Future<List<String>> getPersonalizedRecommendations(
    Map<String, dynamic> userProfile,
  ) async {
    await initialize();

    try {
      final prompt = '''
Based on this user profile, suggest personalized travel recommendations for Kerala:
- Age: ${userProfile['age'] ?? 'Not specified'}
- Interests: ${userProfile['interests'] ?? 'General travel'}
- Budget: ₹${userProfile['budget'] ?? 'Flexible'}
- Travel style: ${userProfile['travelStyle'] ?? 'Balanced'}
- Previous trips: ${userProfile['previousTrips'] ?? 'None'}

Provide 5 specific, actionable recommendations.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final raw = response.text;

      if (raw != null && raw.isNotEmpty) {
        return raw.split('\n').where((line) => line.trim().isNotEmpty).toList();
      }

      return [
        'Visit Munnar for scenic beauty',
        'Try local cuisine in Fort Kochi',
        'Take a backwater cruise in Alleppey',
        'Explore tea plantations in Wayanad',
        'Visit historical sites in Thrissur',
      ];
    } catch (e) {
      print('Error getting recommendations: $e');
      return [
        'Explore local markets',
        'Try traditional food',
        'Visit nearby temples',
        'Take scenic routes',
        'Meet local people',
      ];
    }
  }
}
