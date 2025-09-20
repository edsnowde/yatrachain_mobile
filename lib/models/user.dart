class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime lastActive;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> stats;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
    required this.lastActive,
    this.preferences = const {},
    this.stats = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'lastActive': lastActive.millisecondsSinceEpoch,
        'preferences': preferences,
        'stats': stats,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profileImage: json['profileImage'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        lastActive: DateTime.fromMillisecondsSinceEpoch(json['lastActive']),
        preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
        stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      );

  User copyWith({
    String? name,
    String? email,
    String? profileImage,
    DateTime? lastActive,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? stats,
  }) =>
      User(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        profileImage: profileImage ?? this.profileImage,
        createdAt: createdAt,
        lastActive: lastActive ?? this.lastActive,
        preferences: preferences ?? this.preferences,
        stats: stats ?? this.stats,
      );
}
