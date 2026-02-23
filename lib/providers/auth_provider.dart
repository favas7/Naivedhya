import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  User? get currentUser => _supabase.auth.currentUser;

  AuthProvider() {
    // Restore session on app start
    _restoreSession();
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _restoreSession() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser != null) {
        await _loadUserProfile(supabaseUser.id);
      }
    } catch (e) {
      // Session restore failed silently
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser != null) {
        await _loadUserProfile(supabaseUser.id);
      }
    } catch (e) {
      // Auth check failed silently
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    final userData = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    _user = UserModel.fromJson(userData);
    notifyListeners();
  }

  Future<String?> getUserType() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser != null) {
        return await checkUserType(supabaseUser.id);
      }
      return null;
    } catch (e) {
      return null; // Do NOT default to 'user' for admin app — fail explicitly
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);

        final usertype = await checkUserType(response.user!.id);

        // Block non-admins from logging into admin app
        if (usertype != 'admin') {
          await _supabase.auth.signOut();
          _user = null;
          _isLoading = false;
          notifyListeners();
          return {
            'success': false,
            'usertype': null,
            'user': null,
            'error': 'Access denied. Admin accounts only.',
          };
        }

        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'usertype': usertype,
          'user': _user,
        };
      }

      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'usertype': null,
        'user': null,
        'error': 'Login failed.',
      };

    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String?> checkUserType(String uid) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('usertype')
          .eq('id', uid)
          .maybeSingle(); 

      return response?['usertype']?.toString();
    } catch (e) {
      return null;
    }
  }
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      // Logout error silently ignored
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void refreshUser() {}
}