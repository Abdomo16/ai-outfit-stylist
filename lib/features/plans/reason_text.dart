import '../../data/models/outfit_model.dart';
import '../../l10n/app_localizations.dart';

List<String> localizedReasons(
  AppLocalizations l10n,
  OutfitModel outfit, {
  String? weather,
  String? season,
  String? style,
}) {
  if (outfit.reasonCodes.isEmpty) return outfit.reasons;
  return [
    for (final code in outfit.reasonCodes)
      switch (code.code) {
        'weather' => l10n.reasonWeather(weather ?? ''),
        'season' => l10n.reasonSeason(season ?? ''),
        'style_relaxed' => l10n.reasonStyleRelaxed,
        'style_match' => l10n.reasonStyleMatch(style ?? outfit.stylePreference),
        'repeated_piece' => l10n.reasonRepeated,
        'color_pair' => l10n.reasonColorPair(
          code.colors.isNotEmpty ? code.colors[0] : '',
          code.colors.length > 1 ? code.colors[1] : '',
        ),
        'color_clash' => l10n.reasonColorClash(
          code.colors.isNotEmpty ? code.colors[0] : '',
          code.colors.length > 1 ? code.colors[1] : '',
        ),
        'color_neutral' => l10n.reasonNeutral,
        _ => code.code,
      },
  ];
}
