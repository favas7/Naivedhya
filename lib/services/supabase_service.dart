import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final response = await _client.from('users').select().eq('userId', userId).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      return null;
    }
  }

Future<AuthResponse?> signUp(UserModel user, String password) async {
  try {
    final response = await _client.auth.signUp(email: user.email, password: password);
    if (response.user != null) {
      // Create a new UserModel with the Supabase auth user ID
      final userWithId = user.copyWith(id: response.user!.id);
      await _client.from('users').insert(userWithId.toJson());
    }
    return response;
  } catch (e) {
    return null;
  }
}

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AuthResponse?> googleSignIn() async {
    try {
      final success = await _client.auth.signInWithOAuth(OAuthProvider.google);
      if (success) {
        // Return a mock AuthResponse with the current session
        final session = _client.auth.currentSession;
        if (session != null) {
          return AuthResponse(session: session, user: session.user);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}