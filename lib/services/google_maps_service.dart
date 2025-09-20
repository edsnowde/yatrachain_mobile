import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yatrachain/config/api_keys.dart';

class GoogleMapsService {
  static const String _apiKey = ApiKeys.googleMapsApiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  // Default map configuration
  static const LatLng _defaultCenter =
      LatLng(10.8505, 76.2711); // Kerala center
  static const double _defaultZoom = 10.0;

  // Get map configuration
  static MapConfiguration getMapConfiguration() {
    return MapConfiguration(
      apiKey: _apiKey,
      initialCameraPosition: const CameraPosition(
        target: _defaultCenter,
        zoom: _defaultZoom,
      ),
    );
  }

  // Get directions between two points
  static Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination,
    String travelMode,
  ) async {
    try {
      final url = '$_baseUrl/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&mode=$travelMode'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  // Get place details
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = '$_baseUrl/place/details/json'
          '?place_id=$placeId'
          '&fields=name,formatted_address,geometry,rating,price_level'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // Search for places
  static Future<List<Map<String, dynamic>>> searchPlaces(
    String query,
    LatLng location,
    int radius,
  ) async {
    try {
      final url = '$_baseUrl/place/textsearch/json'
          '?query=$query'
          '&location=${location.latitude},${location.longitude}'
          '&radius=$radius'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  // Get current traffic conditions
  static Future<Map<String, dynamic>?> getTrafficConditions(
    LatLng location,
    int radius,
  ) async {
    try {
      final url = '$_baseUrl/place/nearbysearch/json'
          '?location=${location.latitude},${location.longitude}'
          '&radius=$radius'
          '&type=route'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting traffic conditions: $e');
      return null;
    }
  }

  // Calculate distance between two points
  static Future<double?> calculateDistance(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final directions = await getDirections(
        origin,
        destination,
        'driving',
      );

      if (directions != null && directions['routes'] != null) {
        final routes = directions['routes'] as List;
        if (routes.isNotEmpty) {
          final legs = routes[0]['legs'] as List;
          if (legs.isNotEmpty) {
            return (legs[0]['distance']['value'] as int).toDouble() /
                1000; // Convert to km
          }
        }
      }
      return null;
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }

  // Get estimated travel time
  static Future<Duration?> getEstimatedTravelTime(
    LatLng origin,
    LatLng destination,
    String travelMode,
  ) async {
    try {
      final directions = await getDirections(origin, destination, travelMode);

      if (directions != null && directions['routes'] != null) {
        final routes = directions['routes'] as List;
        if (routes.isNotEmpty) {
          final legs = routes[0]['legs'] as List;
          if (legs.isNotEmpty) {
            final duration = legs[0]['duration']['value'] as int;
            return Duration(seconds: duration);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting travel time: $e');
      return null;
    }
  }
}

class MapConfiguration {
  final String apiKey;
  final CameraPosition initialCameraPosition;

  const MapConfiguration({
    required this.apiKey,
    required this.initialCameraPosition,
  });
}
