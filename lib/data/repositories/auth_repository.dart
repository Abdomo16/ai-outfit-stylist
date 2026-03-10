import 'package:outfit_selctor/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository({SupabaseClient? client})
    : _supabaseClient = client ?? SupabaseConfig.client;

  Future<UserModel> signIn(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Login failed');
    }
    return UserModel(
      id: response.user!.id,
      username: response.user!.userMetadata?['username'] ?? '',
      email: response.user!.email ?? '',
      profilePhotoUrl: response.user!.userMetadata?['profilePhotoUrl'],
    );
  }

  Future<UserModel> signUp(
    String username,
    String email,
    String password,
  ) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    if (response.user == null) {
      throw Exception('Registration failed');
    }
    return UserModel(
      id: response.user!.id,
      username: username,
      email: response.user!.email ?? '',
      profilePhotoUrl: null,
    );
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.id,
      username: user.userMetadata?['username'] ?? '',
      email: user.email ?? '',
      profilePhotoUrl: user.userMetadata?['profilePhotoUrl'],
    );
  }
}
