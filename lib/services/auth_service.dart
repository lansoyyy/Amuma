import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Create user document in Firestore
        await _createUserDocument(user, name);

        // Send email verification
        await user.sendEmailVerification();

        return AuthResult.success(
          user: user,
          message:
              'Account created successfully! Please check your email for verification.',
        );
      } else {
        return AuthResult.failure(message: 'Failed to create account');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        return AuthResult.success(
          user: user,
          message: 'Welcome back!',
        );
      } else {
        return AuthResult.failure(message: 'Failed to sign in');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(
        message: 'Password reset email sent! Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Sign out
  Future<AuthResult> signOut() async {
    try {
      await _auth.signOut();
      return AuthResult.success(message: 'Signed out successfully');
    } catch (e) {
      return AuthResult.failure(message: 'Failed to sign out');
    }
  }

  // Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return AuthResult.success(
          message: 'Verification email sent! Please check your inbox.',
        );
      } else if (user?.emailVerified == true) {
        return AuthResult.failure(message: 'Email is already verified');
      } else {
        return AuthResult.failure(message: 'No user found');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Reload user to check email verification status
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user account
        await user.delete();

        return AuthResult.success(message: 'Account deleted successfully');
      } else {
        return AuthResult.failure(message: 'No user found');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name) async {
    final DocumentReference userDoc =
        _firestore.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': name,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSignIn': FieldValue.serverTimestamp(),
      'profileComplete': false,
      'emailVerified': user.emailVerified,
    };

    await userDoc.set(userData);
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user data in Firestore
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(data);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete() async {
    try {
      final userData = await getUserData();
      return userData?['profileComplete'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get error message from FirebaseAuthException
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}

// Auth result class to handle success/failure states
class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
  });

  factory AuthResult.success({
    String? message,
    User? user,
  }) {
    return AuthResult._(
      isSuccess: true,
      message: message ?? 'Operation successful',
      user: user,
    );
  }

  factory AuthResult.failure({
    required String message,
  }) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}
