import '../../data/models/outfit_model.dart';
import '../../data/datasources/weather_service.dart';

class PlanDay {
  final DateTime date;
  final String occasion;
  final String weather;
  final String season;
  final String? city;
  final OutfitModel outfit;

  /// Other things planned that day after [occasion], e.g. gym after
  /// university. The outfit is chosen for [occasion] only.
  final List<String> later;

  /// Forecast high and low in °C, rounded. Null on plans saved before
  /// they were recorded.
  final int? high;
  final int? low;

  /// The weather is the usual one for the date, not a forecast.
  final bool typical;

  const PlanDay({
    required this.date,
    required this.occasion,
    required this.weather,
    required this.season,
    this.city,
    required this.outfit,
    this.later = const [],
    this.high,
    this.low,
    this.typical = false,
  });

  PlanDay copyWith({
    OutfitModel? outfit,
    String? occasion,
    List<String>? later,
  }) {
    return PlanDay(
      date: date,
      occasion: occasion ?? this.occasion,
      weather: weather,
      season: season,
      city: city,
      outfit: outfit ?? this.outfit,
      later: later ?? this.later,
      high: high,
      low: low,
      typical: typical,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': isoDate(date),
    'occasion': occasion,
    'weather': weather,
    'season': season,
    'city': city,
    'outfit': outfit.toJson(),
    if (later.isNotEmpty) 'later': later,
    'high': ?high,
    'low': ?low,
    if (typical) 'typical': true,
  };

  factory PlanDay.fromJson(Map<String, dynamic> json) {
    final outfitJson = json['outfit'];
    return PlanDay(
      date: DateTime.parse(json['date'] as String),
      occasion: json['occasion'] as String? ?? 'everyday',
      weather: json['weather'] as String? ?? 'mild',
      season: json['season'] as String? ?? 'autumn',
      city: json['city'] as String?,
      high: (json['high'] as num?)?.round(),
      low: (json['low'] as num?)?.round(),
      typical: json['typical'] == true,
      later: [
        for (final occasion in json['later'] as List? ?? const [])
          if (occasion is String) occasion,
      ],
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
