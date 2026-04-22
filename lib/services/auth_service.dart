import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service using Supabase Auth.
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Get the currently signed-in user, if any.
  User? get currentUser => _client.auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    // Create user profile row
    if (response.user != null) {
      await _client.from('user_profiles').upsert({
        'id': response.user!.id,
        'display_name': email.split('@').first,
      });
    }
    return response;
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
