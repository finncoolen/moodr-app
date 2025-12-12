import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userId => currentUser?.id;

  // Get the current session token for API calls
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  AuthProvider() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      // If token refresh fails or user is deleted, sign out
      if (event == AuthChangeEvent.signedOut ||
          event == AuthChangeEvent.userDeleted ||
          event == AuthChangeEvent.tokenRefreshed && data.session == null) {
        debugPrint('Auth state change: $event');
      }
      notifyListeners();
    });
  }

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    // Delete user's data from reports table
    await _supabase.from('reports').delete().eq('user_id', user.id);

    // Delete user's data from transcriptions table
    await _supabase.from('transcriptions').delete().eq('user_id', user.id);

    // Delete the user account (requires admin privileges or RLS policy)
    // Note: This uses Supabase's admin API to delete the user
    // You may need to implement a backend endpoint for this
    await _supabase.auth.admin.deleteUser(user.id);

    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
