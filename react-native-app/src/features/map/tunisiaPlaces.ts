export type TunisiaPlace = {
  name: string;
  nameAr: string;
  latitude: number;
  longitude: number;
};

/** Same 46 places as the Flutter app (tunisia_places.dart). `name` is what is stored in the listing city. */
export const tunisiaPlaces: TunisiaPlace[] = [
  { name: 'Tunis', nameAr: 'تونس', latitude: 36.8065, longitude: 10.1815 },
  { name: 'Ariana', nameAr: 'أريانة', latitude: 36.8665, longitude: 10.1647 },
  { name: 'Ben Arous', nameAr: 'بن عروس', latitude: 36.7531, longitude: 10.2189 },
  { name: 'Manouba', nameAr: 'منوبة', latitude: 36.8101, longitude: 10.0863 },
  { name: 'Nabeul', nameAr: 'نابل', latitude: 36.4513, longitude: 10.7357 },
  { name: 'Zaghouan', nameAr: 'زغوان', latitude: 36.4029, longitude: 10.1429 },
  { name: 'Bizerte', nameAr: 'بنزرت', latitude: 37.2744, longitude: 9.8739 },
  { name: 'Béja', nameAr: 'باجة', latitude: 36.7256, longitude: 9.1817 },
  { name: 'Jendouba', nameAr: 'جندوبة', latitude: 36.5011, longitude: 8.7802 },
  { name: 'Le Kef', nameAr: 'الكاف', latitude: 36.1742, longitude: 8.7049 },
  { name: 'Siliana', nameAr: 'سليانة', latitude: 36.0849, longitude: 9.3708 },
  { name: 'Sousse', nameAr: 'سوسة', latitude: 35.8256, longitude: 10.6084 },
  { name: 'Monastir', nameAr: 'المنستير', latitude: 35.7643, longitude: 10.8113 },
  { name: 'Mahdia', nameAr: 'المهدية', latitude: 35.5047, longitude: 11.0622 },
  { name: 'Sfax', nameAr: 'صفاقس', latitude: 34.7406, longitude: 10.7603 },
  { name: 'Kairouan', nameAr: 'القيروان', latitude: 35.6781, longitude: 10.0963 },
  { name: 'Kasserine', nameAr: 'القصرين', latitude: 35.1676, longitude: 8.8365 },
  { name: 'Sidi Bouzid', nameAr: 'سيدي بوزيد', latitude: 35.0382, longitude: 9.4849 },
  { name: 'Gabès', nameAr: 'قابس', latitude: 33.8815, longitude: 10.0982 },
  { name: 'Médenine', nameAr: 'مدنين', latitude: 33.3549, longitude: 10.5055 },
  { name: 'Tataouine', nameAr: 'تطاوين', latitude: 32.9297, longitude: 10.4518 },
  { name: 'Gafsa', nameAr: 'قفصة', latitude: 34.4250, longitude: 8.7842 },
  { name: 'Tozeur', nameAr: 'توزر', latitude: 33.9197, longitude: 8.1335 },
  { name: 'Kébili', nameAr: 'قبلي', latitude: 33.7044, longitude: 8.9690 },
  { name: 'Hammamet', nameAr: 'الحمامات', latitude: 36.4000, longitude: 10.6167 },
  { name: 'Tabarka', nameAr: 'طبرقة', latitude: 36.9544, longitude: 8.7578 },
  { name: 'Nefta', nameAr: 'نفطة', latitude: 33.8736, longitude: 7.8778 },
  { name: 'Douz', nameAr: 'دوز', latitude: 33.4565, longitude: 9.0207 },
  { name: 'Djerba', nameAr: 'جربة', latitude: 33.8750, longitude: 10.8575 },
  { name: 'Midoun', nameAr: 'ميدون', latitude: 33.8083, longitude: 10.9917 },
  { name: 'Zarzis', nameAr: 'جرجيس', latitude: 33.5036, longitude: 11.1122 },
  { name: 'Sidi Bou Said', nameAr: 'سيدي بوسعيد', latitude: 36.8700, longitude: 10.3413 },
  { name: 'La Marsa', nameAr: 'المرسى', latitude: 36.8782, longitude: 10.3247 },
  { name: 'Carthage', nameAr: 'قرطاج', latitude: 36.8528, longitude: 10.3233 },
  { name: 'Gammarth', nameAr: 'قمرت', latitude: 36.9170, longitude: 10.2890 },
  { name: 'Kélibia', nameAr: 'قليبية', latitude: 36.8475, longitude: 11.0939 },
  { name: 'Korba', nameAr: 'قربة', latitude: 36.5783, longitude: 10.8581 },
  { name: 'Hammam Sousse', nameAr: 'حمام سوسة', latitude: 35.8610, longitude: 10.5986 },
  { name: 'Port El Kantaoui', nameAr: 'ميناء القنطاوي', latitude: 35.8933, longitude: 10.5953 },
  { name: 'Hergla', nameAr: 'هرقلة', latitude: 36.0292, longitude: 10.5083 },
  { name: 'El Jem', nameAr: 'الجم', latitude: 35.2978, longitude: 10.7078 },
  { name: 'Matmata', nameAr: 'مطماطة', latitude: 33.5444, longitude: 9.9697 },
  { name: 'Tamerza', nameAr: 'تمغزة', latitude: 34.3930, longitude: 7.9391 },
  { name: 'Ain Draham', nameAr: 'عين دراهم', latitude: 36.7794, longitude: 8.6903 },
  { name: 'Mateur', nameAr: 'ماطر', latitude: 37.0405, longitude: 9.6652 },
  { name: 'Sbeitla', nameAr: 'سبيطلة', latitude: 35.2325, longitude: 9.1175 },
];

/** Lower case, trimmed, without accents (same as normalizeSearchText in Flutter). */
export function normalizeSearchText(input: string): string {
  return input
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

/** The place with exactly this name (Latin or Arabic), or null. */
export function placeByName(text: string | null | undefined): TunisiaPlace | null {
  const wanted = normalizeSearchText(text ?? '');
  if (wanted === '') {
    return null;
  }
  return (
    tunisiaPlaces.find(
      place => normalizeSearchText(place.name) === wanted || place.nameAr === wanted,
    ) ?? null
  );
}

/** Places containing `query`, those that start with it first. Empty query gives nothing. */
export function searchPlaces(query: string, limit = 8): TunisiaPlace[] {
  const wanted = normalizeSearchText(query);
  if (wanted === '') {
    return [];
  }
  const starts: TunisiaPlace[] = [];
  const contains: TunisiaPlace[] = [];
  for (const place of tunisiaPlaces) {
    const latin = normalizeSearchText(place.name);
    if (latin.startsWith(wanted) || place.nameAr.startsWith(wanted)) {
      starts.push(place);
    } else if (latin.includes(wanted) || place.nameAr.includes(wanted)) {
      contains.push(place);
    }
  }
  return [...starts, ...contains].slice(0, limit);
}
