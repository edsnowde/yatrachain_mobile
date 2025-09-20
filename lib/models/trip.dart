enum TransportMode {
  bus('🚌', 'Bus'),
  walk('🚶', 'Walk'),
  metro('🚇', 'Metro'),
  bike('🚲', 'Bike'),
  auto('🛺', 'Auto'),
  car('🚗', 'Car');

  const TransportMode(this.emoji, this.name);
  final String emoji;
  final String name;
}

enum TripPurpose {
  work('💼', 'Work'),
  education('🎓', 'Education'),
  shopping('🛍️', 'Shopping'),
  leisure('🎭', 'Leisure'),
  medical('🏥', 'Medical'),
  other('📍', 'Other');

  const TripPurpose(this.emoji, this.name);
  final String emoji;
  final String name;
}

class Trip {
  final String id;
  final String from;
  final String to;
  final DateTime startTime;
  final DateTime endTime;
  final TransportMode mode;
  final TripPurpose purpose;
  final double distance;
  final double fare;
  final int companions;
  final List<String> route;

  Trip({
    required this.id,
    required this.from,
    required this.to,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.purpose,
    required this.distance,
    required this.fare,
    this.companions = 1,
    this.route = const [],
  });

  // ---------------- Aliases for HomeScreen ----------------
  String get startLocation => from;
  String get endLocation => to;
  TransportMode get transportMode => mode;
  String get dateString =>
      '${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}';

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
        'mode': mode.name,
        'purpose': purpose.name,
        'distance': distance,
        'fare': fare,
        'companions': companions,
        'route': route,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'],
        from: json['from'],
        to: json['to'],
        startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
        endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime']),
        mode: TransportMode.values
            .firstWhere((e) => e.name == json['mode'], orElse: () => TransportMode.bus),
        purpose: TripPurpose.values
            .firstWhere((e) => e.name == json['purpose'], orElse: () => TripPurpose.other),
        distance: json['distance'].toDouble(),
        fare: json['fare'].toDouble(),
        companions: json['companions'] ?? 1,
        route: List<String>.from(json['route'] ?? []),
      );
}
