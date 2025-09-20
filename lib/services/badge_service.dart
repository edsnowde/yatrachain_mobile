import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yatrachain/models/badge.dart';
import 'package:yatrachain/models/trip.dart';
import 'package:yatrachain/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BadgeService {
  static const String _badgesKey = 'badges';

  Future<List<UserBadge>> getBadges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final badgesJson = prefs.getStringList(_badgesKey);

      if (badgesJson == null || badgesJson.isEmpty) {
        await saveBadges(UserBadge.defaultBadges);
        return UserBadge.defaultBadges;
      }

      return badgesJson
          .map((json) => UserBadge.fromJson(jsonDecode(json)))
          .toList();
    }

    return await FirebaseService.getUserBadges(user.uid);
  }

  Future<void> saveBadges(List<UserBadge> badges) async {
    final prefs = await SharedPreferences.getInstance();
    final badgesJson =
        badges.map((badge) => jsonEncode(badge.toJson())).toList();
    await prefs.setStringList(_badgesKey, badgesJson);
  }

  Future<List<UserBadge>> checkAndUnlockBadges(List<Trip> trips) async {
    final badges = await getBadges();
    final unlockedBadges = <UserBadge>[];
    final user = FirebaseAuth.instance.currentUser;

    final totalDistance = trips.fold(0.0, (sum, trip) => sum + trip.distance);
    final totalSavings = _calculateSavings(trips);
    final ecoTrips = trips
        .where((t) =>
            t.mode == TransportMode.walk ||
            t.mode == TransportMode.bike ||
            t.mode == TransportMode.bus ||
            t.mode == TransportMode.metro)
        .length;
    final companionTrips = trips.where((t) => t.companions > 1).length;

    for (int i = 0; i < badges.length; i++) {
      if (badges[i].unlocked) continue;

      bool shouldUnlock = false;
      switch (badges[i].type) {
        case BadgeType.distance:
          shouldUnlock = totalDistance >= badges[i].requirement;
          break;
        case BadgeType.savings:
          shouldUnlock = totalSavings >= badges[i].requirement;
          break;
        case BadgeType.eco:
          shouldUnlock = ecoTrips >= badges[i].requirement;
          break;
        case BadgeType.explorer:
          final uniqueLocations = <String>{};
          for (var trip in trips) {
            uniqueLocations.addAll(trip.route);
          }
          shouldUnlock = uniqueLocations.length >= badges[i].requirement;
          break;
        case BadgeType.social:
          shouldUnlock = companionTrips >= badges[i].requirement;
          break;
        case BadgeType.smart:
          final smartRoutes = trips
              .where((t) =>
                  t.mode == TransportMode.bus || t.mode == TransportMode.metro)
              .length;
          shouldUnlock = smartRoutes >= badges[i].requirement;
          break;
      }

      if (shouldUnlock) {
        badges[i] = badges[i].copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        );
        unlockedBadges.add(badges[i]);

        // Update in Firebase if authenticated
        if (user != null) {
          await FirebaseService.updateBadge(badges[i], user.uid);
        }
      }
    }

    if (unlockedBadges.isNotEmpty && user == null) {
      // Only save locally if not authenticated
      await saveBadges(badges);
    }

    return unlockedBadges;
  }

  double _calculateSavings(List<Trip> trips) {
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
    return savings;
  }
}
