/// Egypt-specific data for the week plan: the governorates the user can
/// pick as home, and the Ramadan and Eid dates.
library;

class Governorate {
  final String id;
  final String nameEn;
  final String nameAr;

  /// The governorate's capital, used for the forecast.
  final double latitude;
  final double longitude;

  const Governorate(
    this.id,
    this.nameEn,
    this.nameAr,
    this.latitude,
    this.longitude,
  );

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  /// Whether a search for [query] should show this governorate, in either
  /// language and whatever Arabic spelling was typed.
  bool matches(String query) {
    final folded = foldArabic(query.trim().toLowerCase());
    if (folded.isEmpty) return true;
    return nameEn.toLowerCase().contains(folded) ||
        foldArabic(nameAr).contains(folded) ||
        foldArabic(nameAr).replaceFirst('ال', '').contains(folded);
  }

  static Governorate? byId(String? id) {
    for (final governorate in egyptGovernorates) {
      if (governorate.id == id) return governorate;
    }
    return null;
  }
}

/// All 27 governorates, most populous first.
const List<Governorate> egyptGovernorates = [
  Governorate('cairo', 'Cairo', 'القاهرة', 30.0444, 31.2357),
  Governorate('giza', 'Giza', 'الجيزة', 30.0131, 31.2089),
  Governorate('alexandria', 'Alexandria', 'الإسكندرية', 31.2001, 29.9187),
  Governorate('qalyubia', 'Qalyubia', 'القليوبية', 30.4660, 31.1848),
  Governorate('sharqia', 'Sharqia', 'الشرقية', 30.5877, 31.5020),
  Governorate('dakahlia', 'Dakahlia', 'الدقهلية', 31.0409, 31.3785),
  Governorate('gharbia', 'Gharbia', 'الغربية', 30.7865, 31.0004),
  Governorate('monufia', 'Monufia', 'المنوفية', 30.5524, 31.0124),
  Governorate('beheira', 'Beheira', 'البحيرة', 31.0341, 30.4682),
  Governorate(
    'kafr_el_sheikh',
    'Kafr El Sheikh',
    'كفر الشيخ',
    31.1107,
    30.9388,
  ),
  Governorate('damietta', 'Damietta', 'دمياط', 31.4175, 31.8144),
  Governorate('port_said', 'Port Said', 'بورسعيد', 31.2653, 32.3019),
  Governorate('ismailia', 'Ismailia', 'الإسماعيلية', 30.5965, 32.2715),
  Governorate('suez', 'Suez', 'السويس', 29.9668, 32.5498),
  Governorate('north_sinai', 'North Sinai', 'شمال سيناء', 31.1316, 33.7984),
  Governorate('south_sinai', 'South Sinai', 'جنوب سيناء', 28.2410, 33.6222),
  Governorate('red_sea', 'Red Sea', 'البحر الأحمر', 27.2579, 33.8116),
  Governorate('faiyum', 'Faiyum', 'الفيوم', 29.3084, 30.8428),
  Governorate('beni_suef', 'Beni Suef', 'بني سويف', 29.0661, 31.0994),
  Governorate('minya', 'Minya', 'المنيا', 28.1099, 30.7503),
  Governorate('asyut', 'Asyut', 'أسيوط', 27.1783, 31.1859),
  Governorate('sohag', 'Sohag', 'سوهاج', 26.5570, 31.6948),
  Governorate('qena', 'Qena', 'قنا', 26.1551, 32.7160),
  Governorate('luxor', 'Luxor', 'الأقصر', 25.6872, 32.6396),
  Governorate('aswan', 'Aswan', 'أسوان', 24.0889, 32.8998),
  Governorate('new_valley', 'New Valley', 'الوادي الجديد', 25.4390, 30.5586),
  Governorate('matrouh', 'Matrouh', 'مطروح', 31.3543, 27.2373),
];

/// Folds the Arabic spellings people type for the same word: أ إ آ to ا,
/// ة to ه and ى to ي.
String foldArabic(String text) {
  return text
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');
}

enum EgyptSeason { ramadan, eidFitr, eidAdha }

/// Expected first day of Ramadan, Eid al-Fitr and Eid al-Adha in Egypt.
///
/// The real dates follow the moon sighting and can move by a day, so add
/// each new year here once it is announced.
final List<({DateTime ramadan, DateTime fitr, DateTime adha})> _hijriDates = [
  (
    ramadan: DateTime.utc(2026, 2, 18),
    fitr: DateTime.utc(2026, 3, 20),
    adha: DateTime.utc(2026, 5, 27),
  ),
  (
    ramadan: DateTime.utc(2027, 2, 8),
    fitr: DateTime.utc(2027, 3, 10),
    adha: DateTime.utc(2027, 5, 16),
  ),
  (
    ramadan: DateTime.utc(2028, 1, 28),
    fitr: DateTime.utc(2028, 2, 27),
    adha: DateTime.utc(2028, 5, 5),
  ),
  (
    ramadan: DateTime.utc(2029, 1, 16),
    fitr: DateTime.utc(2029, 2, 14),
    adha: DateTime.utc(2029, 4, 24),
  ),
  (
    ramadan: DateTime.utc(2030, 1, 6),
    fitr: DateTime.utc(2030, 2, 5),
    adha: DateTime.utc(2030, 4, 13),
  ),
];

/// Eid al-Fitr is celebrated for three days, Eid al-Adha for four.
const int _fitrDays = 3;
const int _adhaDays = 4;

/// Whether [date] falls in Ramadan or an Eid, or null.
EgyptSeason? egyptSeasonOn(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  bool within(DateTime start, int days) =>
      !day.isBefore(start) && day.isBefore(start.add(Duration(days: days)));
  for (final year in _hijriDates) {
    if (within(year.fitr, _fitrDays)) return EgyptSeason.eidFitr;
    if (within(year.adha, _adhaDays)) return EgyptSeason.eidAdha;
    if (!day.isBefore(year.ramadan) && day.isBefore(year.fitr)) {
      return EgyptSeason.ramadan;
    }
  }
  return null;
}
