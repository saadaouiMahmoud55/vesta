import 'package:latlong2/latlong.dart';

import '../search/search_filters.dart' show normalizeSearchText;

/// A governorate capital, a city or a tourist town of Tunisia, with its
/// position. Used by the city search of the publish form and to place a
/// listing on the map when the owner gave no exact position (VST-42).
///
/// [name] is what is stored in the listing's `city` field (Latin spelling,
/// same as the search); [nameAr] is shown and searched in Arabic.
class TunisiaPlace {
  const TunisiaPlace(this.name, this.nameAr, this.latitude, this.longitude);

  final String name;
  final String nameAr;
  final double latitude;
  final double longitude;

  LatLng get point => LatLng(latitude, longitude);
}

const List<TunisiaPlace> tunisiaPlaces = [
  // Governorate capitals
  TunisiaPlace('Tunis', 'تونس', 36.8065, 10.1815),
  TunisiaPlace('Ariana', 'أريانة', 36.8665, 10.1647),
  TunisiaPlace('Ben Arous', 'بن عروس', 36.7531, 10.2189),
  TunisiaPlace('Manouba', 'منوبة', 36.8101, 10.0863),
  TunisiaPlace('Nabeul', 'نابل', 36.4513, 10.7357),
  TunisiaPlace('Zaghouan', 'زغوان', 36.4029, 10.1429),
  TunisiaPlace('Bizerte', 'بنزرت', 37.2744, 9.8739),
  TunisiaPlace('Béja', 'باجة', 36.7256, 9.1817),
  TunisiaPlace('Jendouba', 'جندوبة', 36.5011, 8.7802),
  TunisiaPlace('Le Kef', 'الكاف', 36.1742, 8.7049),
  TunisiaPlace('Siliana', 'سليانة', 36.0849, 9.3708),
  TunisiaPlace('Sousse', 'سوسة', 35.8256, 10.6084),
  TunisiaPlace('Monastir', 'المنستير', 35.7643, 10.8113),
  TunisiaPlace('Mahdia', 'المهدية', 35.5047, 11.0622),
  TunisiaPlace('Sfax', 'صفاقس', 34.7406, 10.7603),
  TunisiaPlace('Kairouan', 'القيروان', 35.6781, 10.0963),
  TunisiaPlace('Kasserine', 'القصرين', 35.1676, 8.8365),
  TunisiaPlace('Sidi Bouzid', 'سيدي بوزيد', 35.0382, 9.4849),
  TunisiaPlace('Gabès', 'قابس', 33.8815, 10.0982),
  TunisiaPlace('Médenine', 'مدنين', 33.3549, 10.5055),
  TunisiaPlace('Tataouine', 'تطاوين', 32.9297, 10.4518),
  TunisiaPlace('Gafsa', 'قفصة', 34.4250, 8.7842),
  TunisiaPlace('Tozeur', 'توزر', 33.9197, 8.1335),
  TunisiaPlace('Kébili', 'قبلي', 33.7044, 8.9690),
  // Cities and tourist towns
  TunisiaPlace('Hammamet', 'الحمامات', 36.4000, 10.6167),
  TunisiaPlace('Tabarka', 'طبرقة', 36.9544, 8.7578),
  TunisiaPlace('Nefta', 'نفطة', 33.8736, 7.8778),
  TunisiaPlace('Douz', 'دوز', 33.4565, 9.0207),
  TunisiaPlace('Djerba', 'جربة', 33.8750, 10.8575),
  TunisiaPlace('Midoun', 'ميدون', 33.8083, 10.9917),
  TunisiaPlace('Zarzis', 'جرجيس', 33.5036, 11.1122),
  TunisiaPlace('Sidi Bou Said', 'سيدي بوسعيد', 36.8700, 10.3413),
  TunisiaPlace('La Marsa', 'المرسى', 36.8782, 10.3247),
  TunisiaPlace('Carthage', 'قرطاج', 36.8528, 10.3233),
  TunisiaPlace('Gammarth', 'قمرت', 36.9170, 10.2890),
  TunisiaPlace('Kélibia', 'قليبية', 36.8475, 11.0939),
  TunisiaPlace('Korba', 'قربة', 36.5783, 10.8581),
  TunisiaPlace('Hammam Sousse', 'حمام سوسة', 35.8610, 10.5986),
  TunisiaPlace('Port El Kantaoui', 'ميناء القنطاوي', 35.8933, 10.5953),
  TunisiaPlace('Hergla', 'هرقلة', 36.0292, 10.5083),
  TunisiaPlace('El Jem', 'الجم', 35.2978, 10.7078),
  TunisiaPlace('Matmata', 'مطماطة', 33.5444, 9.9697),
  TunisiaPlace('Tamerza', 'تمغزة', 34.3930, 7.9391),
  TunisiaPlace('Ain Draham', 'عين دراهم', 36.7794, 8.6903),
  TunisiaPlace('Mateur', 'ماطر', 37.0405, 9.6652),
  TunisiaPlace('Sbeitla', 'سبيطلة', 35.2325, 9.1175),
];

/// The place with exactly this name (Latin or Arabic), ignoring case and
/// accents. null when the text is not a known place.
TunisiaPlace? placeByName(String? text) {
  final wanted = normalizeSearchText(text ?? '');
  if (wanted.isEmpty) return null;
  for (final place in tunisiaPlaces) {
    if (normalizeSearchText(place.name) == wanted ||
        place.nameAr == wanted) {
      return place;
    }
  }
  return null;
}

/// Places whose name (Latin or Arabic) contains [query], those that START
/// with it first. At most [limit]. An empty query gives nothing.
List<TunisiaPlace> searchPlaces(String query, {int limit = 8}) {
  final wanted = normalizeSearchText(query);
  if (wanted.isEmpty) return const [];
  final starts = <TunisiaPlace>[];
  final contains = <TunisiaPlace>[];
  for (final place in tunisiaPlaces) {
    final latin = normalizeSearchText(place.name);
    if (latin.startsWith(wanted) || place.nameAr.startsWith(wanted)) {
      starts.add(place);
    } else if (latin.contains(wanted) || place.nameAr.contains(wanted)) {
      contains.add(place);
    }
  }
  return [...starts, ...contains].take(limit).toList();
}
