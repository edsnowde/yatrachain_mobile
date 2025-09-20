import 'package:yatrachain/models/chat_message.dart';
import 'package:yatrachain/services/firebase_service.dart';
import 'package:yatrachain/services/gemini_ai_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotService {
  static final Map<String, String> _responses = {
    'hello':
        'നമസ്കാരം! YatraBot here 🤖 How can I help you with your travels today?',
    'cheapest route':
        'The cheapest route to Thrissur is by bus: ₹45 via Aluva-Chalakudy. Takes about 1.5 hours 🚌',
    'last trips':
        'Your last trip was from Kochi to Thrissur yesterday. You saved ₹12 by choosing the optimal route! 💰',
    'less crowded':
        'Try the 7:30 AM bus to avoid crowds. Current occupancy: 65%. Alternative: Metro at 8:00 AM 🚇',
    'traffic update':
        'NH66 has moderate traffic near Aluva. Expect 15-minute delay. Consider the backwaters route! 🛣️',
    'weather':
        'Perfect weather for travel today! ☀️ Temperature: 28°C. Light breeze from the Arabian Sea.',
    'help':
        'I can help you with:\n• Route suggestions\n• Fare comparisons\n• Traffic updates\n• Weather info\n• Trip history',
    'badges':
        'You\'re close to unlocking "100 km Club"! Just 15 km to go. Keep traveling smart! 🏆',
    'stats':
        'Your travel stats:\n• Distance: 85 km\n• Money saved: ₹340\n• Carbon saved: 12.5 kg CO₂\n• Trips: 15',
  };

  static final List<String> _quickReplies = [
    'Cheapest route',
    'Less crowded option',
    'Last trips',
    'Traffic update',
    'My badges',
    'Travel stats',
  ];

  Future<ChatMessage> getBotResponse(
    String userMessage, {
    List<ChatMessage>? chatHistory,
    Map<String, dynamic>? userContext,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate thinking

    final message = userMessage.toLowerCase();

    // Try Gemini AI first for enhanced responses
    try {
      final aiResponse = await GeminiAIService.getAIResponse(
        userMessage,
        chatHistory: chatHistory,
        userContext: userContext,
      );

      // Save to Firebase if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseService.addChatMessage(aiResponse, user.uid);
      }

      return aiResponse;
    } catch (e) {
      print('Gemini AI error, falling back to local responses: $e');

      // Fallback to local responses
      String response = _responses[message] ?? _getSmartResponse(message);

      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response,
        isBot: true,
        timestamp: DateTime.now(),
        quickReplies: _quickReplies,
      );

      // Save to Firebase if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseService.addChatMessage(botMessage, user.uid);
      }

      return botMessage;
    }
  }

  String _getSmartResponse(String message) {
    if (message.contains('route') || message.contains('direction')) {
      return 'I can help you find the best route! Where would you like to go? 🗺️';
    } else if (message.contains('bus') || message.contains('transport')) {
      return 'For bus routes, I recommend checking the live map for real-time updates. Shall I show crowding levels? 🚌';
    } else if (message.contains('save') || message.contains('cheap')) {
      return 'Great question! Walking and cycling save the most money. Bus routes via major highways are also efficient 💰';
    } else if (message.contains('time') || message.contains('fast')) {
      return 'Metro is usually fastest for long distances. For short trips, walking might be quicker than waiting! ⚡';
    } else if (message.contains('thank')) {
      return 'You\'re welcome! Happy travels with YatraChain! 🚀';
    }

    return 'That\'s interesting! Could you be more specific? I can help with routes, fares, traffic, or travel tips 🤔';
  }

  List<String> getQuickReplies() => _quickReplies;
}
