import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Initialize GoogleSignIn with optional web client ID
  // For web, you need to add a meta tag in web/index.html or pass clientId here
  late final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AuthService() {
    // Initialize GoogleSignIn conditionally
    if (kIsWeb) {
      // For web, use the Web Client ID from Firebase Console
      _googleSignIn = GoogleSignIn(
        clientId: '840648616109-80hmdcihg106e66a3272saa4mn63imnf.apps.googleusercontent.com',
      );
    } else {
      // For mobile platforms
      _googleSignIn = GoogleSignIn();
    }
  }
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await _getUserData(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Sign up with email and password
  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String name,
    String addictionType,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        
        // Create user document in Firestore
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          addictionType: addictionType,
          recoveryStartDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _createUserDocument(user);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final userData = await _getUserData(userCredential.user!.uid);
        
        if (userData != null) {
          return userData;
        } else {
          // New Google user - needs onboarding for addiction type
          return UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName,
            photoUrl: userCredential.user!.photoURL,
            addictionType: '', // Will be set during onboarding
            recoveryStartDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
      return null;
    } catch (e) {
      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }
  
  // Sign in anonymously
  Future<UserModel?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        // Create anonymous user document
        final user = UserModel(
          id: credential.user!.uid,
          email: 'anonymous@aitherapist.app',
          name: 'Anonymous User',
          addictionType: '', // Will be set during onboarding
          recoveryStartDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _createUserDocument(user);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Complete onboarding (set addiction type)
  Future<void> completeOnboarding(String userId, String addictionType) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'addictionType': addictionType,
        'recoveryStartDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Failed to complete onboarding: ${e.toString()}';
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Update user profile
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (preferences != null) updates['preferences'] = preferences;
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
      
      // Update Firebase Auth display name
      if (name != null && currentUser != null) {
        await currentUser!.updateDisplayName(name);
      }
    } catch (e) {
      throw 'Failed to update profile: ${e.toString()}';
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }
  
  // Delete account
  Future<void> deleteAccount(String userId) async {
    try {
      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();
      
      // Delete auth account
      await currentUser?.delete();
    } catch (e) {
      throw 'Failed to delete account: ${e.toString()}';
    }
  }
  
  // Private helper methods
  Future<UserModel?> _getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  Future<void> _createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      throw 'Failed to create user document: ${e.toString()}';
    }
  }
  
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
