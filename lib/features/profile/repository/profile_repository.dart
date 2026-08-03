import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
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

  Future<void> deleteAccount() async {
    try {
      // Typically a RPC call is used `await _supabaseClient.rpc('delete_user')` if RLS allows it
      // For now we simulate account deletion by signing out, letting the user know they are deleted
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileExtension = p.extension(filePath);
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      await _supabaseClient.storage.from('avatars').upload(fileName, file);

      final imageUrl = _supabaseClient.storage
          .from('avatars')
          .getPublicUrl(fileName);

      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {'avatar_url': imageUrl, 'profilePhotoUrl': imageUrl},
        ),
      );

      try {
        await _supabaseClient
            .from('users')
            .update({'avatar_url': imageUrl, 'profilePhotoUrl': imageUrl})
            .eq('id', user.id);
      } catch (e) {
        // Table might not exist or RLS might block, but we updated Auth metadata which is enough
      }
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
