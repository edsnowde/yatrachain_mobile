import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yatrachain/services/firebase_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  // Initialize notifications
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      print('FCM Token: $_fcmToken');

      // Save token to user profile
      await _saveTokenToUserProfile();

      // Set up message handlers
      _setupMessageHandlers();
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Save FCM token to user profile
  static Future<void> _saveTokenToUserProfile() async {
    if (_fcmToken != null) {
      try {
        final user = await FirebaseService.getCurrentUser();
        if (user != null) {
          final updatedUser = user.copyWith(
            preferences: {
              ...user.preferences,
              'fcmToken': _fcmToken,
              'notificationsEnabled': true,
            },
          );
          await FirebaseService.updateUser(updatedUser);
        }
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }

  // Set up message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message);
    });
  }

  // Show local notification
  static void _showLocalNotification(RemoteMessage message) {
    // This would typically use a local notification plugin
    // For now, we'll just print the notification
    print('Local Notification: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    if (data['type'] == 'trip_reminder') {
      // Navigate to trip screen
      print('Navigate to trip screen');
    } else if (data['type'] == 'badge_unlocked') {
      // Navigate to profile/badges screen
      print('Navigate to badges screen');
    } else if (data['type'] == 'route_update') {
      // Navigate to map screen
      print('Navigate to map screen');
    }
  }

  // Send trip reminder notification
  static Future<void> sendTripReminder({
    required String tripId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // This would typically use a cloud function or admin SDK
      // For now, we'll simulate the notification
      print('Sending trip reminder: $title');
      print('Scheduled for: $scheduledTime');
    } catch (e) {
      print('Error sending trip reminder: $e');
    }
  }

  // Send badge unlocked notification
  static Future<void> sendBadgeUnlockedNotification({
    required String badgeTitle,
    required String badgeDescription,
  }) async {
    try {
      print('Badge unlocked: $badgeTitle');
      print('Description: $badgeDescription');

      // This would trigger a local notification
      _showLocalNotification(RemoteMessage(
        data: {
          'type': 'badge_unlocked',
          'badge_title': badgeTitle,
          'badge_description': badgeDescription,
        },
        notification: RemoteNotification(
          title: '🏆 Badge Unlocked!',
          body: 'You earned: $badgeTitle',
        ),
      ));
    } catch (e) {
      print('Error sending badge notification: $e');
    }
  }

  // Send route update notification
  static Future<void> sendRouteUpdateNotification({
    required String routeName,
    required String updateMessage,
  }) async {
    try {
      print('Route update: $routeName');
      print('Message: $updateMessage');

      _showLocalNotification(RemoteMessage(
        data: {
          'type': 'route_update',
          'route_name': routeName,
          'update_message': updateMessage,
        },
        notification: RemoteNotification(
          title: '🚌 Route Update',
          body: updateMessage,
        ),
      ));
    } catch (e) {
      print('Error sending route update: $e');
    }
  }

  // Send weather alert notification
  static Future<void> sendWeatherAlert({
    required String location,
    required String weatherCondition,
    required String recommendation,
  }) async {
    try {
      print('Weather alert for $location: $weatherCondition');

      _showLocalNotification(RemoteMessage(
        data: {
          'type': 'weather_alert',
          'location': location,
          'condition': weatherCondition,
        },
        notification: RemoteNotification(
          title: '🌤️ Weather Alert',
          body: '$weatherCondition in $location. $recommendation',
        ),
      ));
    } catch (e) {
      print('Error sending weather alert: $e');
    }
  }

  // Send trip completion notification
  static Future<void> sendTripCompletionNotification({
    required String tripId,
    required double distance,
    required double savings,
    required double carbonSaved,
  }) async {
    try {
      print('Trip completed: $tripId');

      _showLocalNotification(RemoteMessage(
        data: {
          'type': 'trip_completed',
          'trip_id': tripId,
          'distance': distance.toString(),
          'savings': savings.toString(),
          'carbon_saved': carbonSaved.toString(),
        },
        notification: RemoteNotification(
          title: '✅ Trip Completed!',
          body:
              'Distance: ${distance.toStringAsFixed(1)} km, Saved: ₹${savings.toStringAsFixed(0)}',
        ),
      ));
    } catch (e) {
      print('Error sending trip completion notification: $e');
    }
  }

  // Get FCM token
  static String? get fcmToken => _fcmToken;

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Disable notifications
  static Future<void> disableNotifications() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;

      // Update user profile
      final user = await FirebaseService.getCurrentUser();
      if (user != null) {
        final updatedUser = user.copyWith(
          preferences: {
            ...user.preferences,
            'notificationsEnabled': false,
          },
        );
        await FirebaseService.updateUser(updatedUser);
      }
    } catch (e) {
      print('Error disabling notifications: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');

  // Handle background message
  if (message.data['type'] == 'trip_reminder') {
    print('Background trip reminder received');
  } else if (message.data['type'] == 'badge_unlocked') {
    print('Background badge notification received');
  }
}
