/// Places in Egypt a trip can go to: the main tourist spots and every
/// governorate, each with what a trip there is usually for.
library;

import 'egypt.dart';

class Destination {
  final String id;
  final String nameEn;
  final String nameAr;
  final double latitude;
  final double longitude;

  /// What a trip there is usually for, e.g. beach on the Red Sea. The
  /// user can change it.
  final String occasion;

  /// Other names people search by, e.g. "Sahel" for the North Coast.
  final List<String> aliases;

  const Destination(
    this.id,
    this.nameEn,
    this.nameAr,
    this.latitude,
    this.longitude, {
    this.occasion = 'everyday',
    this.aliases = const [],
  });

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  bool matches(String query) => nameMatches(query, nameEn, nameAr, aliases);
}

/// Occasions a trip day can be dressed for, in the order they are offered.
const List<String> tripOccasions = [
  'everyday',
  'sightseeing',
  'beach',
  'wedding',
  'family',
  'party',
  'date night',
  'formal',
  'work',
];

/// Tourist spots, whose weather can differ a lot from their governorate's
/// capital (Saint Catherine is up in the mountains, Siwa out in the desert).
const List<Destination> _spots = [
  Destination(
    'sharm',
    'Sharm El Sheikh',
    'شرم الشيخ',
    27.9158,
    34.3300,
    occasion: 'beach',
  ),
  Destination(
    'hurghada',
    'Hurghada',
    'الغردقة',
    27.2579,
    33.8116,
    occasion: 'beach',
    aliases: ['ghardaqa'],
  ),
  Destination(
    'north_coast',
    'North Coast',
    'الساحل الشمالي',
    30.8300,
    28.9550,
    occasion: 'beach',
    aliases: ['sahel', 'alamein', 'العلمين'],
  ),
  Destination('dahab', 'Dahab', 'دهب', 28.5091, 34.5136, occasion: 'beach'),
  Destination(
    'el_gouna',
    'El Gouna',
    'الجونة',
    27.3949,
    33.6782,
    occasion: 'beach',
  ),
  Destination(
    'marsa_alam',
    'Marsa Alam',
    'مرسى علم',
    25.0676,
    34.8790,
    occasion: 'beach',
  ),
  Destination(
    'ain_sokhna',
    'Ain Sokhna',
    'العين السخنة',
    29.5800,
    32.3300,
    occasion: 'beach',
    aliases: ['sokhna'],
  ),
  Destination(
    'siwa',
    'Siwa',
    'سيوة',
    29.2032,
    25.5195,
    occasion: 'sightseeing',
  ),
  Destination(
    'pyramids',
    'Giza Pyramids',
    'أهرامات الجيزة',
    29.9792,
    31.1342,
    occasion: 'sightseeing',
    aliases: ['الهرم'],
  ),
  Destination(
    'abu_simbel',
    'Abu Simbel',
    'أبو سمبل',
    22.3372,
    31.6258,
    occasion: 'sightseeing',
  ),
  Destination(
    'saint_catherine',
    'Saint Catherine',
    'سانت كاترين',
    28.5559,
    33.9761,
    occasion: 'sightseeing',
  ),
  Destination('taba', 'Taba', 'طابا', 29.4925, 34.8969, occasion: 'beach'),
  Destination(
    'nuweiba',
    'Nuweiba',
    'نويبع',
    29.0333,
    34.6667,
    occasion: 'beach',
  ),
  Destination(
    'ras_sudr',
    'Ras Sudr',
    'رأس سدر',
    29.5833,
    32.7000,
    occasion: 'beach',
  ),
];

/// What a trip to a governorate is usually for; the rest are everyday.
const Map<String, String> _governorateOccasions = {
  'red_sea': 'beach',
  'south_sinai': 'beach',
  'matrouh': 'beach',
  'luxor': 'sightseeing',
  'aswan': 'sightseeing',
};

/// Every place a trip can go to: the tourist spots first, then all 27
/// governorates.
final List<Destination> egyptDestinations = [
  ..._spots,
  for (final governorate in egyptGovernorates)
    Destination(
      governorate.id,
      governorate.nameEn,
      governorate.nameAr,
      governorate.latitude,
      governorate.longitude,
      occasion: _governorateOccasions[governorate.id] ?? 'everyday',
    ),
];

/// Shown as chips before the user types anything.
const List<String> _popularIds = [
  'sharm',
  'hurghada',
  'north_coast',
  'dahab',
  'el_gouna',
  'marsa_alam',
  'ain_sokhna',
  'luxor',
  'aswan',
  'siwa',
  'alexandria',
  'cairo',
];

List<Destination> get popularDestinations => [
  for (final id in _popularIds)
    egyptDestinations.firstWhere((place) => place.id == id),
];

/// The places matching [query], tourist spots first.
List<Destination> searchDestinations(String query) => [
  for (final place in egyptDestinations)
    if (place.matches(query)) place,
];
