import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../models/outfit_model.dart';

class WearLogRepository {
  WearLogRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<void> saveWorn(OutfitModel outfit, DateTime day) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    await _client.from('wear_logs').upsert({
      'user_id': userId,
      'worn_on': _day(day),
      'outfit_data': outfit.toJson(),
    }, onConflict: 'user_id,worn_on');
  }

  Future<List<String>> recentItemIds({int days = 3}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final start = DateTime.now().subtract(Duration(days: days));
    final rows = await _client
        .from('wear_logs')
        .select('outfit_data')
        .eq('user_id', userId)
        .gte('worn_on', _day(start));
    final ids = <String>{};
    for (final row in rows) {
      final data = row['outfit_data'];
      if (data is! Map) continue;
      final items = data['items'];
      if (items is! List) continue;
      for (final item in items) {
        if (item is! Map) continue;
        final id = item['id']?.toString();
        if (id != null && id.isNotEmpty) ids.add(id);
      }
    }
    return ids.toList();
  }

  String _day(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
