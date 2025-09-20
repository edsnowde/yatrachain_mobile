enum BadgeType {
  distance('🏃', 'Distance Master'),
  savings('💰', 'Money Saver'),
  eco('🌿', 'Eco Warrior'),
  explorer('🗺️', 'Kerala Explorer'),
  social('👥', 'Social Traveler'),
  smart('🧠', 'Smart Router');

  const BadgeType(this.emoji, this.name);
  final String emoji;
  final String name;
}

class UserBadge {
  final String id;
  final BadgeType type;
  final String title;
  final String description;
  final int requirement;
  final bool unlocked;
  final DateTime? unlockedAt;

  UserBadge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.requirement,
    this.unlocked = false,
    this.unlockedAt,
  });

  UserBadge copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
  }) => UserBadge(
    id: id,
    type: type,
    title: title,
    description: description,
    requirement: requirement,
    unlocked: unlocked ?? this.unlocked,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'requirement': requirement,
    'unlocked': unlocked,
    'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
  };

  factory UserBadge.fromJson(Map<String, dynamic> json) => UserBadge(
    id: json['id'],
    type: BadgeType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'],
    description: json['description'],
    requirement: json['requirement'],
    unlocked: json['unlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt']) 
        : null,
  );

  static List<UserBadge> defaultBadges = [
    UserBadge(
      id: 'distance_100',
      type: BadgeType.distance,
      title: '100 km Club',
      description: 'Travel 100+ kilometers',
      requirement: 100,
    ),
    UserBadge(
      id: 'savings_1000',
      type: BadgeType.savings,
      title: 'Smart Spender',
      description: 'Save ₹1000+ with smart routes',
      requirement: 1000,
    ),
    UserBadge(
      id: 'eco_50',
      type: BadgeType.eco,
      title: 'Green Traveler',
      description: 'Take 50+ eco-friendly trips',
      requirement: 50,
    ),
    UserBadge(
      id: 'explorer_kerala',
      type: BadgeType.explorer,
      title: 'Kerala Explorer',
      description: 'Visit 10+ districts in Kerala',
      requirement: 10,
    ),
    UserBadge(
      id: 'social_100',
      type: BadgeType.social,
      title: 'Group Leader',
      description: 'Travel with companions 100+ times',
      requirement: 100,
    ),
    UserBadge(
      id: 'smart_router',
      type: BadgeType.smart,
      title: 'Route Master',
      description: 'Use optimal routes 25+ times',
      requirement: 25,
    ),
  ];
}