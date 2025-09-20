import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yatrachain/models/badge.dart';

class DatabaseInit {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize database with default data
  static Future<void> initializeDatabase() async {
    await _createDefaultBadges();
    await _createIndexes();
  }

  // Create default badges in the database
  static Future<void> _createDefaultBadges() async {
    final badgesRef = _firestore.collection('default_badges');

    for (var badge in UserBadge.defaultBadges) {
      await badgesRef.doc(badge.id).set(badge.toJson());
    }
  }

  // Create Firestore indexes for better query performance
  static Future<void> _createIndexes() async {
    // Note: Firestore indexes are typically created through the Firebase Console
    // or using the Firebase CLI. This is just a placeholder for documentation.

    // Recommended indexes for the app:
    // 1. trips collection: userId (ascending), startTime (descending)
    // 2. badges collection: userId (ascending), type (ascending)
    // 3. chat_messages collection: userId (ascending), timestamp (descending)

    print('Database indexes should be created through Firebase Console or CLI');
  }

  // Create sample data for testing
  static Future<void> createSampleData(String userId) async {
    // This method can be used to populate the database with sample data
    // for testing purposes
    print('Sample data creation for user: $userId');
  }

  // Database schema documentation
  static Map<String, dynamic> getDatabaseSchema() {
    return {
      'collections': {
        'users': {
          'fields': [
            'id',
            'name',
            'email',
            'profileImage',
            'createdAt',
            'lastActive',
            'preferences',
            'stats'
          ],
          'indexes': ['id']
        },
        'trips': {
          'fields': [
            'id',
            'userId',
            'from',
            'to',
            'startTime',
            'endTime',
            'mode',
            'purpose',
            'distance',
            'fare',
            'companions',
            'route',
            'isActive'
          ],
          'indexes': ['userId', 'startTime', 'isActive']
        },
        'badges': {
          'fields': [
            'id',
            'userId',
            'type',
            'title',
            'description',
            'requirement',
            'unlocked',
            'unlockedAt'
          ],
          'indexes': ['userId', 'type']
        },
        'chat_messages': {
          'fields': [
            'id',
            'userId',
            'message',
            'isBot',
            'timestamp',
            'quickReplies',
            'confidence'
          ],
          'indexes': ['userId', 'timestamp']
        },
        'default_badges': {
          'fields': ['id', 'type', 'title', 'description', 'requirement'],
          'indexes': ['type']
        }
      },
      'security_rules': {
        'users': 'Users can read/write their own data',
        'trips': 'Users can read/write their own trips',
        'badges': 'Users can read/write their own badges',
        'chat_messages': 'Users can read/write their own messages',
        'default_badges': 'All users can read, no write access'
      }
    };
  }
}
