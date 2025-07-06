import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> checkAuthStatus() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        final userData = await _supabaseService.getUser(session.user.id);
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
    final response = await _supabaseService.signIn(email, password);
    
    if (response?.user != null) {
      final userData = await _supabaseService.getUser(response!.user!.id);
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
    return false;
  }
}

  Future<bool> signUp(UserModel user, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Sign up the user with Supabase using email and password
      final response = await _supabaseService.signUp(user, password);
      if (response != null && response.user != null) {
        // Save user data to the profiles table
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'userId': user.userId,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'dob': user.dob,
          'address': user.address,
          'pending_payments': user.pendingPayments,
          'order_history': user.orderHistory,
          'created_at': user.createdAt.toIso8601String(),
          'updated_at': user.updatedAt.toIso8601String(),
          'user_type': user.userType,
        });

        _user = user.copyWith(id: response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      debugPrint('SignUp failed: No user returned');
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      if (e.message.contains('Database error saving new user')) {
        debugPrint('Check your database triggers or RLS policies.');
      }
      _isLoading = false;
      notifyListeners();
      throw Exception('Sign-up failed: ${e.message}'); // User-friendly error
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('An unexpected error occurred during sign-up. Please try again.'); // User-friendly error
    }
  }

  Future<void> logout() async {
    try {
      await _supabaseService.signOut();
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
      final response = await _supabaseService.googleSignIn();
      if (response != null && response.user != null) {
        // Save or update user data in profiles table
        await supabase.from('profiles').upsert({
          'id': response.user!.id,
          'userId': response.user!.id,
          'name': response.user!.userMetadata?['full_name'] ?? 'Unknown',
          'email': response.user!.email,
          'phone': '',
          'dob': '',
          'address': '',
          'pending_payments': 0.0,
          'order_history': [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'user_type': 'user',
        });

        final userData = await _supabaseService.getUser(response.user!.id);
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
      return false;
    }
  }
}