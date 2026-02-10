import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // FIXED: Web requires explicit clientId
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
      ? '964586361849-refd5en4n6p53g0jruufcl87e2riioof.apps.googleusercontent.com'
      : null,
  );
  
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get user data from Supabase database
  Future<Map<String, dynamic>?> getUser(String userid) async {
    try {
      final response = await _supabase.from('profiles').select().eq('id', userid).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Sign up with email and password
  Future<User?> signUp(UserModel user, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      
      if (credential.user != null) {
        final userWithId = user.copyWith(
          id: credential.user!.uid,
          userid: credential.user!.uid,
        );
        await _supabase.from('profiles').insert(userWithId.toJson());
      }
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  // FIXED: Google Sign In with web support
  Future<User?> googleSignIn() async {
    try {
      GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        // Web: Try silent sign-in first
        googleUser = await _googleSignIn.signInSilently();
        
        // If silent sign-in fails, use popup (this is the unreliable part)
        googleUser ??= await _googleSignIn.signIn();
        
      } else {
        // Mobile: Use standard sign-in
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _supabase.from('profiles').upsert({
          'id': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'Unknown',
          'email': userCredential.user!.email,
          'phone': '',
          'dob': '',
          'address': '',
          'pendingpayments': 0.0,
          'orderhistory': [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'usertype': 'user',
        });
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      // Catch Google Sign-In specific errors
      if (kIsWeb) {
        throw Exception('Google Sign-In failed on web. Make sure popup blockers are disabled.');
      }
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}