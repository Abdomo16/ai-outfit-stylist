import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class PlanRepository {
  PlanRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<String> save({
    required String kind,
    required String title,
    required DateTime startsOn,
    required List<Map<String, dynamic>> days,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    final row = await _client
        .from('outfit_plans')
        .insert({
          'user_id': userId,
          'kind': kind,
          'title': title,
          'starts_on': _day(startsOn),
          'days': days,
        })
        .select('id')
        .single();
    return row['id'].toString();
  }

  Future<void> updateDays(String id, List<Map<String, dynamic>> days) async {
    await _client.from('outfit_plans').update({'days': days}).eq('id', id);
  }

  Future<Map<String, dynamic>?> latest(String kind) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final rows = await _client
        .from('outfit_plans')
        .select()
        .eq('user_id', userId)
        .eq('kind', kind)
        .order('created_at', ascending: false)
        .limit(1);
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  String _day(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
