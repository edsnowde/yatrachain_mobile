import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yatrachain/models/trip.dart';
import 'package:yatrachain/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripService {
  static const String _tripsKey = 'trips';
  static const String _currentTripKey = 'current_trip';

  static final List<Trip> _sampleTrips = [
    Trip(
      id: '1',
      from: 'Kochi',
      to: 'Thrissur',
      startTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      mode: TransportMode.bus,
      purpose: TripPurpose.work,
      distance: 75.2,
      fare: 45.0,
      companions: 1,
      route: ['Kochi', 'Aluva', 'Chalakudy', 'Thrissur'],
    ),
    Trip(
      id: '2',
      from: 'Thrissur',
      to: 'Palakkad',
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      mode: TransportMode.metro,
      purpose: TripPurpose.shopping,
      distance: 52.8,
      fare: 35.0,
      companions: 2,
      route: ['Thrissur', 'Shoranur', 'Palakkad'],
    ),
    Trip(
      id: '3',
      from: 'Home',
      to: 'Office',
      startTime: DateTime.now().subtract(const Duration(hours: 8)),
      endTime: DateTime.now().subtract(const Duration(hours: 7, minutes: 45)),
      mode: TransportMode.walk,
      purpose: TripPurpose.work,
      distance: 2.1,
      fare: 0.0,
      companions: 1,
      route: ['Home', 'Park', 'Office'],
    ),
    Trip(
      id: '4',
      from: 'Kottayam',
      to: 'Alleppey',
      startTime: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
      endTime: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
      mode: TransportMode.bus,
      purpose: TripPurpose.leisure,
      distance: 32.5,
      fare: 25.0,
      companions: 3,
      route: ['Kottayam', 'Changanassery', 'Alleppey'],
    ),
    Trip(
      id: '5',
      from: 'Trivandrum',
      to: 'Kollam',
      startTime: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
      mode: TransportMode.auto,
      purpose: TripPurpose.medical,
      distance: 68.4,
      fare: 120.0,
      companions: 1,
      route: ['Trivandrum', 'Attingal', 'Kollam'],
    ),
  ];

  Future<List<Trip>> getTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Fallback to local storage if not authenticated
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getStringList(_tripsKey);

      if (tripsJson == null || tripsJson.isEmpty) {
        await saveTrips(_sampleTrips);
        return _sampleTrips;
      }

      return tripsJson.map((json) => Trip.fromJson(jsonDecode(json))).toList();
    }

    return await FirebaseService.getUserTrips(user.uid);
  }

  Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = trips.map((trip) => jsonEncode(trip.toJson())).toList();
    await prefs.setStringList(_tripsKey, tripsJson);
  }

  Future<void> addTrip(Trip trip) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Fallback to local storage
      final trips = await getTrips();
      trips.add(trip);
      await saveTrips(trips);
    } else {
      await FirebaseService.addTrip(trip, user.uid);
    }
  }

  Future<Trip?> getCurrentTrip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final tripJson = prefs.getString(_currentTripKey);
      if (tripJson == null) return null;
      return Trip.fromJson(jsonDecode(tripJson));
    }

    return await FirebaseService.getCurrentTrip(user.uid);
  }

  Future<void> setCurrentTrip(Trip? trip) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      if (trip == null) {
        await prefs.remove(_currentTripKey);
      } else {
        await prefs.setString(_currentTripKey, jsonEncode(trip.toJson()));
      }
    } else {
      await FirebaseService.setCurrentTrip(trip, user.uid);
    }
  }

  Future<void> updateTrip(Trip updatedTrip) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Fallback to local storage
      final trips = await getTrips();
      final index = trips.indexWhere((t) => t.id == updatedTrip.id);

      if (index != -1) {
        trips[index] = updatedTrip;
        await saveTrips(trips);
      }
    } else {
      await FirebaseService.updateTrip(updatedTrip);
    }
  }

  double getTotalDistance(List<Trip> trips) =>
      trips.fold(0.0, (sum, trip) => sum + trip.distance);

  double getTotalSavings(List<Trip> trips) {
    double savings = 0.0;
    for (var trip in trips) {
      switch (trip.mode) {
        case TransportMode.walk:
          savings += 15.0; // Saved bus fare
          break;
        case TransportMode.bike:
          savings += 8.0; // Saved fuel cost
          break;
        case TransportMode.bus:
          savings += trip.distance * 0.5; // Efficient route
          break;
        default:
          break;
      }
    }
    return savings;
  }

  double getCarbonSaved(List<Trip> trips) {
    double carbonSaved = 0.0;
    for (var trip in trips) {
      switch (trip.mode) {
        case TransportMode.walk:
          carbonSaved += trip.distance * 0.25; // kg CO2 saved
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
    return carbonSaved;
  }
}
