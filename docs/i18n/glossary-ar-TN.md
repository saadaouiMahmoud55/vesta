# Tunisian Arabic glossary and tone guide (ar-TN)

Status: **draft**, to be read by Manar and by one Tunisian reader outside the team (VST-77). Terms marked "?" need a native check.
Source of the existing terms: `flutter-app/lib/l10n/app_ar.arb` and `docs/offer-types.md` section 6.

## 1. Tone guide

1. Talk to the user in the singular, friendly and polite, like the current app texts ("ادخل باش تكمل").
2. Short sentences. One idea per sentence.
3. Buttons are verbs in the imperative: ادخل, ابعث, احذف, احفظ.
4. Messages and hints may use Tunisian words (باش, برشا, ما ... ش). Titles and buttons prefer words that every Arabic reader understands.
5. No mix of scripts in one sentence. Exceptions: numbers (Latin digits), `TND`, and the name Vesta.
6. Numbers in Latin digits: 450, 120,000. Never Arabic-Indic digits (٤٥٠).
7. Arabic is written right to left. Numbers and `TND` stay left to right inside Arabic sentences.
8. Do not translate word for word from French or English. Write what a Tunisian would really say.

## 2. Money (TND)

Format decided by Manar (review of PR #41): the currency comes first, then the amount, with a comma as thousands separator. No space inside the number.

| Rule | English | Français | العربية |
|---|---|---|---|
| Sale | `TND 120,000` | `TND 120,000` | `TND 120,000` |
| Per night | `TND 150 / night` | `TND 150 / nuit` | `TND 150 / ليلة` |
| Per month | `TND 900 / month` | `TND 900 / mois` | `TND 900 / شهر` |
| Per year | `TND 5,000 / year` | `TND 5,000 / an` | `TND 5,000 / سنة` |

- Thousands separator: a comma (`120,000`), in the three languages.
- The currency `TND` comes first, then the amount, then the unit. `formatPrice` is the only function that formats a price (spec VST-100).
- In right-to-left screens the whole price (`TND 120,000 / ليلة`) stays in one left-to-right block, and the Arabic unit follows it. To check on a phone set to Arabic.
- Numbers always use Latin digits (0 to 9), never Arabic-Indic digits.

## 3. Terms: listings and properties

| Key term | English | Français | العربية (تونسي) | Note |
|---|---|---|---|---|
| listing | Listing | Annonce | إعلان | app_ar |
| offer.sale | For sale | À vendre | للبيع | spec |
| offer.rent | For rent | À louer | للكراء | spec |
| offer.stay | Stay | Séjour | إقامة | spec |
| tab.buy | Buy | Acheter | شراء | spec |
| tab.rent | Rent | Louer | كراء | spec |
| tab.stay | Stay | Séjourner | إقامة | spec |
| price | Price | Prix | السوم | Tunisian word, app_ar |
| city | City | Ville | المدينة | app_ar |
| governorate | Governorate | Gouvernorat | الولاية | |
| apartment | Apartment | Appartement | شقة | app_ar |
| house | House | Maison | دار | app_ar |
| villa | Villa | Villa | فيلا | app_ar |
| studio | Studio | Studio | ستوديو | app_ar |
| riad | Riad | Riad | رياض | app_ar |
| guest house | Guest house | Maison d'hôtes | دار ضيافة | app_ar |
| land | Land | Terrain | أرض | ? |
| commercial | Commercial | Local commercial | محل تجاري | ? |
| rooms | Rooms | Chambres | بيوت | in Tunisian, بيت means a room (app_ar) |
| bathrooms | Bathrooms | Salles de bain | بيوت الماء | app_ar, ? |
| area | Area (m²) | Surface (m²) | المساحة (م²) | app_ar |
| furnished | Furnished | Meublé | مفروش | spec |
| negotiable | Negotiable | Négociable | قابل للتفاوض | spec |
| status.sold | Sold | Vendu | مباع | spec |
| status.rented | Rented | Loué | مكري | spec |
| status.reserved | Reserved | Réservé | محجوز | spec |
| no longer available | No longer available | N'est plus disponible | ما عادش متوفر | replaces the stiffer "لم يعد متاحا" |
| guest | Guest | Voyageur | ضيف | |
| host | Host | Hôte | المضيف | |
| owner | Owner | Propriétaire | المالك | app_ar |

## 4. Terms: app actions

| Key term | English | Français | العربية (تونسي) | Note |
|---|---|---|---|---|
| favorites | Favorites | Favoris | المفضلة | app_ar |
| search | Search | Recherche | بحث | app_ar |
| explore | Explore | Explorer | اكتشف | app_ar |
| filters | Filters | Filtres | فلاتر | ? or التصفية |
| all | All | Tous | الكل | filter chip |
| map | Map | Carte | الخريطة | app_ar |
| chat | Chat | Messages | الرسائل | app_ar |
| message | Message | Message | رسالة | |
| send | Send | Envoyer | ابعث | imperative, Tunisian |
| notifications | Notifications | Notifications | الإشعارات | app_ar |
| profile | Profile | Profil | حسابي | app_ar |
| settings | Settings | Paramètres | الإعدادات | |
| language | Language | Langue | اللغة | app_ar |
| log in | Log in | Se connecter | دخول | app_ar, button |
| sign up | Sign up | Créer un compte | إنشاء حساب | app_ar |
| log out | Log out | Se déconnecter | خروج | app_ar |
| email | Email | E-mail | البريد الإلكتروني | app_ar |
| password | Password | Mot de passe | كلمة السر | app_ar, Tunisian |
| full name | Full name | Nom complet | الاسم الكامل | app_ar |
| publish | Publish | Publier | انشر إعلان | app_ar |
| save | Save | Enregistrer | احفظ | |
| edit | Edit | Modifier | بدّل | ? |
| delete | Delete | Supprimer | احذف | app_ar |
| cancel | Cancel | Annuler | إلغاء | |
| retry | Try again | Réessayer | عاود جرّب | app_ar |
| remove | Remove | Retirer | شيل | ? or احذف |
| accept | Accept | Accepter | اقبل | |
| decline | Decline | Refuser | ارفض | |
| booking request | Booking request | Demande de réservation | طلب حجز | Sprint 3 |
| visit request | Visit request | Demande de visite | طلب زيارة | Sprint 3 |
| call | Call | Appeler | اتصل | |
| WhatsApp | WhatsApp | WhatsApp | واتساب | brand name stays in Latin letters in a Latin context |
| share | Share | Partager | شارك | |
| report | Report | Signaler | بلّغ | ? |
| block | Block | Bloquer | احظر | ? |
| delete account | Delete account | Supprimer mon compte | احذف حسابي | |
| review | Review | Avis | رأي | ? |
| rating | Rating | Note | التقييم | |
| gallery | Gallery | Galerie | المعرض | app_ar |
| camera | Camera | Appareil photo | الكاميرا | app_ar |
| photos | Photos | Photos | الصور | app_ar |
| verified | Verified | Vérifié | موثّق | badge |
| coming soon | Coming soon | Bientôt disponible | قريبا | app_ar |

## 5. Terms: stay and amenities

| Key term | English | Français | العربية (تونسي) | Note |
|---|---|---|---|---|
| per night | per night | / nuit | / ليلة | spec |
| per month | per month | / mois | / شهر | spec |
| per year | per year | / an | / سنة | spec |
| check-in | Check-in | Arrivée | الوصول | ? |
| check-out | Check-out | Départ | المغادرة | ? |
| max guests | Max guests | Voyageurs max | أقصى عدد ضيوف | |
| beds | Beds | Lits | الفرشات | ? |
| bedrooms | Bedrooms | Chambres | بيوت النوم | ? see also "rooms" in section 3 |
| bathrooms | Bathrooms | Salles de bain | بيوت الماء | ? same term as section 3 |
| kitchen | Kitchen | Cuisine | كوزينة | Tunisian word |
| wifi | Wi-Fi | Wi-Fi | واي فاي | |
| air conditioning | Air conditioning | Climatisation | مكيّف | ? |
| heating | Heating | Chauffage | تسخين | ? |
| parking | Parking | Parking | موقف سيارات | ? |
| pool | Pool | Piscine | مسبح | |
| terrace | Terrace | Terrasse | تيراس | ? |
| sea view | Sea view | Vue sur mer | إطلالة على البحر | |
| pets allowed | Pets allowed | Animaux acceptés | الحيوانات مسموحة | |
| breakfast | Breakfast | Petit-déjeuner | فطور الصباح | |
| washing machine | Washing machine | Machine à laver | غسالة | |
| TV | TV | Télévision | تلفزة | |
| garden | Garden | Jardin | جنينة | Tunisian word |
| no smoking | No smoking | Non-fumeur | ممنوع التدخين | |
| no pets | No pets | Animaux interdits | ممنوع الحيوانات | |
| no parties | No parties | Fêtes interdites | ممنوع الحفلات | |
| quiet hours | Quiet hours | Heures calmes | ساعات الهدوء | |

## 6. Messages and errors

| Situation | English | Français | العربية (تونسي) | Note |
|---|---|---|---|---|
| no network | No internet connection | Pas de connexion internet | ما فماش اتصال بالإنترنت | app_ar |
| something went wrong | Something went wrong, try again | Une erreur est survenue, réessaie | صار مشكل، عاود جرّب | app_ar |
| wrong password | Wrong email or password | E-mail ou mot de passe incorrect | البريد الإلكتروني أو كلمة السر غالطين | app_ar |
| field required | This field is required | Ce champ est obligatoire | هذا الحقل مطلوب | ? |
| email in use | This email is already used | Cet e-mail est déjà utilisé | البريد هذا مستعمل من قبل | app_ar |
| password too short | Password must be at least 8 characters | Le mot de passe doit contenir au moins 8 caractères | كلمة السر لازم تكون 8 حروف على الأقل | app_ar |
| sign in to continue | Sign in to continue | Connecte-toi pour continuer | ادخل باش تكمل | app_ar |
| permission denied | You are not allowed to do this | Tu n'as pas le droit de faire cela | ما عندكش الصلاحية باش تعمل هذا | app_ar |
| no favorites | No favorites yet | Aucun favori pour l'instant | ما عندكش مفضلة توا | proposal, to replace the formal draft in the app |
| no listings | No listings yet | Aucune annonce pour l'instant | ما فماش إعلانات توا | proposal |
| saved | Saved | Enregistré | تم الحفظ | |

## 7. Review checklist (VST-77, point 4)

- [ ] Manar has read the file and corrected the terms marked "?" (she starts with بيوت الماء and شيل).
- [x] One Tunisian reader outside the team has read it and corrected the terms that sound strange.
- [ ] Ahmed confirms the file is enough to fill `app_ar` and the React Native `ar` file (VST-70).
