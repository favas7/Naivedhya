import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

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

Future<bool> login(String email, String password) async {
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
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
    
  } catch (e) {
    debugPrint('Login error: $e');
    _isLoading = false;
    notifyListeners();
    throw Exception(e.toString().replaceAll('Exception: ', ''));
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
}