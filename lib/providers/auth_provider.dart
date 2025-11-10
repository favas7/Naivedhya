import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
final _supabase = Supabase.instance.client;

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  get currentUser => null;

  Future<void> checkAuthStatus() async {
    try {
      final firebaseUser = _firebaseService.currentUser;
      if (firebaseUser != null) {
        final userData = await _firebaseService.getUser(firebaseUser.uid);
        if (userData != null) {
          _user = UserModel.fromJson(userData);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Check auth status error: $e');
    }
  }

  // Add this method for splash screen to get user type
  Future<String?> getUserType() async {
    try {
      final firebaseUser = _firebaseService.currentUser;
      if (firebaseUser != null) {
        return await checkUserType(firebaseUser.uid);
      }
      return null;
    } catch (e) {
      debugPrint('Get user type error: $e');
      return 'user'; // Default to user if error
    }
  }

  // Updated login method in your AuthProvider
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Attempting sign-in for $email');
      final firebaseUser = await _firebaseService.signIn(email, password);
      debugPrint('Sign-in result: $firebaseUser');
      
      if (firebaseUser != null) {
        debugPrint('Fetching user data for UID: ${firebaseUser.uid}');
        final userData = await _firebaseService.getUser(firebaseUser.uid);
        debugPrint('User data result: $userData');
        
        if (userData != null) {
          _user = UserModel.fromJson(userData);
          
          // Check usertype from Supabase profiles table
          debugPrint('Checking user type for UID: ${firebaseUser.uid}');
          final usertype = await checkUserType(firebaseUser.uid);
          debugPrint('User type result: $usertype');
          
          _isLoading = false;
          notifyListeners();
          
          return {
            'success': true,
            'usertype': usertype,
            'user': _user,
          };
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'usertype': null,
        'user': null,
      };
      
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Helper method to check user type from Supabase (add this if not already present)
  Future<String?> checkUserType(String uid) async {
    try {
      // Replace with your actual Supabase client and query
      final response = await _supabase
          .from('profiles')
          .select('usertype')
          .eq('id', uid)
          .single();
      
      if (response['usertype'] != null) {
        return response['usertype'].toString();
      }
      
      // Default to 'user' if no usertype found
      return 'user';
    } catch (e) {
      debugPrint('Error checking user type: $e');
      // Default to 'user' if there's an error
      return 'user';
    }
  }

  Future<bool> signUp(UserModel user, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final firebaseUser = await _firebaseService.signUp(user, password);
      
      if (firebaseUser != null) {
        _user = user.copyWith(id: firebaseUser.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      debugPrint('SignUp failed: No user returned');
      _isLoading = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      debugPrint('SignUp error: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<bool> googleSignIn() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final firebaseUser = await _firebaseService.googleSignIn();
      
      if (firebaseUser != null) {
        final userData = await _firebaseService.getUser(firebaseUser.uid);
        if (userData != null) {
          _user = UserModel.fromJson(userData);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      debugPrint('Google SignIn failed: No user returned');
      _isLoading = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      debugPrint('Google SignIn error: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      debugPrint('Password reset error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void refreshUser() {}
}