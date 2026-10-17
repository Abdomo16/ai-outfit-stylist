import '../../data/models/outfit_model.dart';
import '../../data/datasources/weather_service.dart';

class PlanDay {
  final DateTime date;
  final String occasion;
  final String weather;
  final String season;
  final String? city;
  final OutfitModel outfit;

  const PlanDay({
    required this.date,
    required this.occasion,
    required this.weather,
    required this.season,
    this.city,
    required this.outfit,
  });

  PlanDay copyWith({OutfitModel? outfit}) {
    return PlanDay(
      date: date,
      occasion: occasion,
      weather: weather,
      season: season,
      city: city,
      outfit: outfit ?? this.outfit,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': isoDate(date),
    'occasion': occasion,
    'weather': weather,
    'season': season,
    'city': city,
    'outfit': outfit.toJson(),
  };

  factory PlanDay.fromJson(Map<String, dynamic> json) {
    final outfitJson = json['outfit'];
    return PlanDay(
      date: DateTime.parse(json['date'] as String),
      occasion: json['occasion'] as String? ?? 'everyday',
      weather: json['weather'] as String? ?? 'mild',
      season: json['season'] as String? ?? 'autumn',
      city: json['city'] as String?,
      outfit: OutfitModel.fromJson(
        outfitJson is Map<String, dynamic>
            ? outfitJson
            : Map<String, dynamic>.from(outfitJson as Map),
      ),
    );
  }
}

class TripStop {
  final String label;
  final double latitude;
  final double longitude;
  final DateTime start;
  final DateTime end;

  const TripStop({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.start,
    required this.end,
  });
}
