import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:yatrachain/models/user.dart';
import 'package:yatrachain/models/trip.dart';
import 'package:yatrachain/models/badge.dart';
import 'package:yatrachain/models/chat_message.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _tripsCollection = 'trips';
  static const String _badgesCollection = 'badges';
  static const String _chatMessagesCollection = 'chat_messages';

  // User operations
  static Future<User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc =
        await _firestore.collection(_usersCollection).doc(user.uid).get();

    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<void> createUser(User user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .set(user.toJson());
  }

  static Future<void> updateUser(User user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .update(user.toJson());
  }

  // Trip operations
  static Future<List<Trip>> getUserTrips(String userId) async {
    final snapshot = await _firestore
        .collection(_tripsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => Trip.fromJson(doc.data())).toList();
  }

  static Future<void> addTrip(Trip trip, String userId) async {
    final tripData = trip.toJson();
    tripData['userId'] = userId;
    await _firestore.collection(_tripsCollection).doc(trip.id).set(tripData);
  }

  static Future<void> updateTrip(Trip trip) async {
    await _firestore
        .collection(_tripsCollection)
        .doc(trip.id)
        .update(trip.toJson());
  }

  static Future<void> deleteTrip(String tripId) async {
    await _firestore.collection(_tripsCollection).doc(tripId).delete();
  }

  static Future<Trip?> getCurrentTrip(String userId) async {
    final snapshot = await _firestore
        .collection(_tripsCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Trip.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  static Future<void> setCurrentTrip(Trip? trip, String userId) async {
    if (trip == null) {
      // Remove current active trip
      final snapshot = await _firestore
          .collection(_tripsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'isActive': false});
      }
    } else {
      // Set new active trip
      await _firestore.collection(_tripsCollection).doc(trip.id).update({
        'isActive': true,
        'userId': userId,
      });
    }
  }

  // Badge operations
  static Future<List<UserBadge>> getUserBadges(String userId) async {
    final snapshot = await _firestore
        .collection(_badgesCollection)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) {
      // Initialize with default badges
      await _initializeUserBadges(userId);
      return UserBadge.defaultBadges;
    }

    return snapshot.docs.map((doc) => UserBadge.fromJson(doc.data())).toList();
  }

  static Future<void> _initializeUserBadges(String userId) async {
    for (var badge in UserBadge.defaultBadges) {
      final badgeData = badge.toJson();
      badgeData['userId'] = userId;
      await _firestore
          .collection(_badgesCollection)
          .doc('${userId}_${badge.id}')
          .set(badgeData);
    }
  }

  static Future<void> updateBadge(UserBadge badge, String userId) async {
    final badgeData = badge.toJson();
    badgeData['userId'] = userId;
    await _firestore
        .collection(_badgesCollection)
        .doc('${userId}_${badge.id}')
        .update(badgeData);
  }

  // Chat operations
  static Future<List<ChatMessage>> getChatMessages(String userId) async {
    final snapshot = await _firestore
        .collection(_chatMessagesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromJson(doc.data()))
        .toList();
  }

  static Future<void> addChatMessage(ChatMessage message, String userId) async {
    final messageData = message.toJson();
    messageData['userId'] = userId;
    await _firestore
        .collection(_chatMessagesCollection)
        .doc(message.id)
        .set(messageData);
  }

  // Statistics operations
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    final trips = await getUserTrips(userId);

    final totalDistance = trips.fold(0.0, (sum, trip) => sum + trip.distance);
    final totalFare = trips.fold(0.0, (sum, trip) => sum + trip.fare);
    final totalTrips = trips.length;

    // Calculate savings
    double savings = 0.0;
    for (var trip in trips) {
      switch (trip.mode) {
        case TransportMode.walk:
          savings += 15.0;
          break;
        case TransportMode.bike:
          savings += 8.0;
          break;
        case TransportMode.bus:
          savings += trip.distance * 0.5;
          break;
        default:
          break;
      }
    }

    // Calculate carbon saved
    double carbonSaved = 0.0;
    for (var trip in trips) {
      switch (trip.mode) {
        case TransportMode.walk:
          carbonSaved += trip.distance * 0.25;
          break;
        case TransportMode.bike:
          carbonSaved += trip.distance * 0.15;
          break;
        case TransportMode.bus:
          carbonSaved += trip.distance * 0.08;
          break;
        case TransportMode.metro:
          carbonSaved += trip.distance * 0.05;
          break;
        default:
          break;
      }
    }

    return {
      'totalDistance': totalDistance,
      'totalFare': totalFare,
      'totalTrips': totalTrips,
      'savings': savings,
      'carbonSaved': carbonSaved,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<void> updateUserStats(
      String userId, Map<String, dynamic> stats) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .update({'stats': stats});
  }
}
