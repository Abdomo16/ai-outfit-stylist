import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../../../../config/supabase_config.dart';

class ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepository({SupabaseClient? client})
    : _supabaseClient = client ?? SupabaseConfig.client;

  Future<ProfileModel> getUserProfile() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      try {
        final response = await _supabaseClient
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        return ProfileModel.fromMap(response);
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST205') {
          return ProfileModel(
            id: user.id,
            name: user.userMetadata?['username'] ?? 'User',
            email: user.email ?? '',
            avatarUrl:
                user.userMetadata?['avatar_url'] ??
                user.userMetadata?['profilePhotoUrl'],
            isPremium: false,
          );
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }
}
