import '../../l10n/app_localizations.dart';
import 'egypt.dart';
import 'plan_day.dart';

/// Above this the day is very hot (°C).
const int veryHot = 35;

/// A swing this big between the day's high and low calls for a layer.
const int bigSwing = 10;

enum DayTip { rain, veryHot, cold, coolEvening, ramadan, eid }

/// Short advice for [day] from its forecast and the Egyptian calendar,
/// most useful first.
List<DayTip> tipsFor(PlanDay day) {
  final tips = <DayTip>[];
  final high = day.high;
  final low = day.low;
  if (day.weather == 'rain') {
    tips.add(DayTip.rain);
  } else if (high != null && high >= veryHot) {
    tips.add(DayTip.veryHot);
  } else if (day.weather == 'cold') {
    tips.add(DayTip.cold);
  }
  if (high != null && low != null && high - low >= bigSwing) {
    tips.add(DayTip.coolEvening);
  }
  switch (egyptSeasonOn(day.date)) {
    case EgyptSeason.ramadan:
      tips.add(DayTip.ramadan);
    case EgyptSeason.eidFitr || EgyptSeason.eidAdha:
      tips.add(DayTip.eid);
    case null:
      break;
  }
  return tips;
}

String tipText(AppLocalizations l10n, DayTip tip) {
  return switch (tip) {
    DayTip.rain => l10n.tipRain,
    DayTip.veryHot => l10n.tipVeryHot,
    DayTip.cold => l10n.tipCold,
    DayTip.coolEvening => l10n.tipCoolEvening,
    DayTip.ramadan => l10n.tipRamadan,
    DayTip.eid => l10n.tipEid,
  };
}

/// The name of the Egyptian season [date] falls in, for a badge.
String? egyptSeasonLabel(AppLocalizations l10n, DateTime date) {
  return switch (egyptSeasonOn(date)) {
    EgyptSeason.ramadan => l10n.ramadan,
    EgyptSeason.eidFitr => l10n.eidFitr,
    EgyptSeason.eidAdha => l10n.eidAdha,
    null => null,
  };
}
