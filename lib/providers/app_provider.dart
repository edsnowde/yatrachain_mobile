import 'package:flutter/material.dart';
import 'package:yatrachain/models/trip.dart';
import 'package:yatrachain/models/badge.dart';
import 'package:yatrachain/models/chat_message.dart';
import 'package:yatrachain/services/trip_service.dart';
import 'package:yatrachain/services/badge_service.dart';
import 'package:yatrachain/services/chatbot_service.dart';
import 'dart:math';

class AppProvider extends ChangeNotifier {
  final TripService _tripService = TripService();
  final BadgeService _badgeService = BadgeService();
  final ChatbotService _chatbotService = ChatbotService();

  // ---------------- Trips & Badges ----------------
  List<Trip> _trips = [];
  List<UserBadge> _badges = [];
  final List<ChatMessage> _chatMessages = [];
  Trip? _currentTrip;

  // ---------------- User Info ----------------
  String _userName = 'Traveler';
  String _userEmail = '';
  String _userPhone = '';

  // ---------------- Preferences ----------------
  bool _isDarkMode = false;
  String _currentLanguage = 'en';

  // ---------------- Onboarding ----------------
  bool _hasOnboarded = false;

  // ---------------- Getters ----------------
  List<Trip> get trips => _trips;
  List<UserBadge> get badges => _badges;
  List<ChatMessage> get chatMessages => _chatMessages;
  Trip? get currentTrip => _currentTrip;
  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  bool get hasOnboarded => _hasOnboarded;

  double get totalDistance => _tripService.getTotalDistance(_trips);
  double get totalSavings => _tripService.getTotalSavings(_trips);
  double get carbonSaved => _tripService.getCarbonSaved(_trips);
  int get unlockedBadgesCount => _badges.where((b) => b.unlocked).length;

  // ---------------- Onboarding Setter ----------------
  void setHasOnboarded(bool value) {
    _hasOnboarded = value;
    notifyListeners();
  }

  // ---------------- Data Load ----------------
  Future<void> loadData() async {
    _trips = await _tripService.getTrips();
    _badges = await _badgeService.getBadges();
    _currentTrip = await _tripService.getCurrentTrip();

    if (_chatMessages.isEmpty) {
      _chatMessages.add(ChatMessage(
        id: '0',
        message:
            'Welcome to YatraBot! 🚀\nI\'m here to help you navigate Kerala smartly. Ask me about routes, fares, or travel tips!',
        isBot: true,
        timestamp: DateTime.now(),
        quickReplies: _chatbotService.getQuickReplies(),
        confidence: 1.0,
      ));
    }

    notifyListeners();
  }

  // ---------------- Trip Actions ----------------
  Future<void> addTrip(Trip trip) async {
    await _tripService.addTrip(trip);
    _trips.add(trip);

    final newBadges = await _badgeService.checkAndUnlockBadges(_trips);
    if (newBadges.isNotEmpty) {
      _badges = await _badgeService.getBadges();
    }

    notifyListeners();
  }

  Future<void> startTrip(Trip trip) async {
    _currentTrip = trip;
    await _tripService.setCurrentTrip(trip);
    notifyListeners();
  }

  Future<void> endCurrentTrip() async {
    if (_currentTrip != null) {
      await addTrip(_currentTrip!);
      _currentTrip = null;
      await _tripService.setCurrentTrip(null);
    }
  }

  Future<void> updateTrip(Trip updatedTrip) async {
    await _tripService.updateTrip(updatedTrip);
    final index = _trips.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      _trips[index] = updatedTrip;
      notifyListeners();
    }
  }

  // ---------------- Chatbot ----------------
  Future<void> sendChatMessage(String message) async {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isBot: false,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(userMessage);
    notifyListeners();

    final botResponse = await _chatbotService.getBotResponse(message);

    // Assign a random confidence between 0.5 and 1.0 for demo purposes
    final randomConfidence = 0.5 + Random().nextDouble() * 0.5;

    final botMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: botResponse.message,
      isBot: true,
      timestamp: DateTime.now(),
      quickReplies: botResponse.quickReplies,
      confidence: randomConfidence,
    );

    _chatMessages.add(botMessage);
    notifyListeners();
  }

  // ---------------- Preferences ----------------
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'ml' : 'en';
    notifyListeners();
  }

  // ---------------- User Info Setters ----------------
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  void setUserPhone(String phone) {
    _userPhone = phone;
    notifyListeners();
  }

  // ---------------- Greeting ----------------
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (_currentLanguage == 'ml') {
      if (hour < 12) return 'സുപ്രഭാതം';
      if (hour < 17) return 'ശുഭ ഉച്ച';
      return 'സുഭ സായാഹ്നം';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      return 'Good Evening';
    }
  }

  // ---------------- Trip Filters ----------------
  List<Trip> getTodayTrips() {
    final today = DateTime.now();
    return _trips
        .where((trip) =>
            trip.startTime.year == today.year &&
            trip.startTime.month == today.month &&
            trip.startTime.day == today.day)
        .toList();
  }

  List<Trip> getThisWeekTrips() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _trips.where((trip) => trip.startTime.isAfter(weekStart)).toList();
  }
}
