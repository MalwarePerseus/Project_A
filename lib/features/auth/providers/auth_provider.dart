// lib/features/auth/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_alarmy/data/models/user_model.dart';

// Provider for auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for current user data
final userDataProvider = FutureProvider<UserModel?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  if (doc.exists) {
    return UserModel.fromJson(doc.data()!);
  }

  return null;
});

// Auth notifier for authentication operations
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final user = _auth.currentUser;
    state = AsyncValue.data(user);
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      state = const AsyncValue.loading();

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!, displayName);

      state = AsyncValue.data(userCredential.user);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = const AsyncValue.loading();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLoginAt': DateTime.now().toIso8601String()},
      );

      state = AsyncValue.data(userCredential.user);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  //Sign in with google
  Future<bool> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();

      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const AsyncValue.data(null);
        return false;
      }

      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        // Create user document for new users
        await _createUserDocument(
          userCredential.user!,
          userCredential.user!.displayName ?? googleUser.displayName ?? '',
        );
      } else {
        // Update last login timestamp for existing users
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': DateTime.now().toIso8601String()});
      }

      state = AsyncValue.data(userCredential.user);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String displayName) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoURL: user.photoURL ?? '',
      isPremium: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
  }
}

// Provider for auth operations
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  return AuthNotifier();
});
