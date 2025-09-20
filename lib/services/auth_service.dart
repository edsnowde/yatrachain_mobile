import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:yatrachain/models/user.dart';
import 'package:yatrachain/services/firebase_service.dart';

class AuthService {
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Get current user
  static auth.User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  static Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<auth.User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Create account with email and password
  static Future<auth.User?> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        final user = User(
          id: credential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await FirebaseService.createUser(user);
        return credential.user;
      }
      return null;
    } catch (e) {
      throw Exception('Account creation failed: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile
  static Future<void> updateUserProfile(User user) async {
    await FirebaseService.updateUser(user);
  }

  // Get user profile from Firestore
  static Future<User?> getUserProfile() async {
    return await FirebaseService.getCurrentUser();
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
}
