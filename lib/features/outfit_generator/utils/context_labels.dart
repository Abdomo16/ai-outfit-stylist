import '../../../l10n/app_localizations.dart';

/// Labels for the values the backend sends back, such as "date night" or
/// "rain". Unknown values are shown as they are.
class ContextLabels {
  static String occasion(AppLocalizations l10n, String value) {
    return switch (value.trim().toLowerCase()) {
      'everyday' => l10n.occasionEveryday,
      'university' => l10n.occasionUniversity,
      'work' => l10n.occasionWork,
      'date night' || 'date_night' => l10n.occasionDateNight,
      'gym' => l10n.occasionGym,
      'party' => l10n.occasionParty,
      'travel' => l10n.occasionTravel,
      'formal' => l10n.occasionFormal,
      'family' => l10n.occasionFamily,
      'beach' => l10n.occasionBeach,
      'sightseeing' => l10n.occasionSightseeing,
      'wedding' => l10n.occasionWedding,
      _ => value,
    };
  }

  static String weather(AppLocalizations l10n, String value) {
    return switch (value) {
      'hot' => l10n.weatherHot,
      'mild' => l10n.weatherMild,
      'cold' => l10n.weatherCold,
      'rain' => l10n.weatherRain,
      _ => value,
    };
  }

  static String season(AppLocalizations l10n, String value) {
    return switch (value) {
      'summer' => l10n.seasonSummer,
      'winter' => l10n.seasonWinter,
      'spring' => l10n.seasonSpring,
      'autumn' => l10n.seasonAutumn,
      _ => value,
    };
  }
}
