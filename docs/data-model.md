# Modèle de données Firestore de Vesta (v4)

Référence unique des collections Firestore utilisées par les deux applications (Flutter et React Native).
Les prix sont stockés sous forme de nombre avec un code de devise. Le code de devise est lu dans la configuration de l'application (TND) et n'est jamais écrit en dur dans les applications ni dans les règles.

**v4 (VST-74, 27 octobre) :** ajoute les champs des trois types d'offre (vente, location, séjour, voir `docs/offer-types.md`), le `status` d'une annonce, deux nouveaux types de bien (`land`, `commercial`), le contact de l'annonce dans un document protégé séparé, et la lecture publique des annonces pour la navigation en invité (VST-72). **Chaque nouveau champ est optionnel** : les annonces publiées avant la v4 restent valides et modifiables.

| Collection | Identifiant du document | Champs (type) | Résumé des règles |
|---|---|---|---|
| `users` | `uid` d'authentification | `displayName` (chaîne), `photoBase64` (chaîne, optionnelle, compressée, moins de 200 Ko), `createdAt` (horodatage serveur) | Création, modification, suppression : l'utilisateur seulement. Lecture : tout utilisateur connecté (profil public, affiché dans les annonces et le chat). |
| `users/{uid}/private/contact` | `contact` | `email` (chaîne), `phone` (chaîne, optionnelle) | Lecture et écriture : l'utilisateur seulement. |
| `listings` | identifiant automatique | `ownerId` (chaîne), `title` (chaîne), `description` (chaîne), `price` (nombre, supérieur à 0), `currency` (chaîne de 3 lettres, issue de la configuration, TND), `rentPeriod` (`"night"`, `"month"` ou `"year"`, obligatoire seulement si `listingType` vaut `"rent"`), `listingType` (`"sale"` ou `"rent"`), `propertyType` (chaîne, valeurs ci-dessous), `city` (chaîne), `latitude` (nombre, optionnel), `longitude` (nombre, optionnel), `bedrooms` (nombre, optionnel), `bathrooms` (nombre, optionnel), `areaSqm` (nombre, optionnel, mètres carrés), `photoCount` (entier de 0 à 10, synchronisé avec les photos, voir les décisions), `createdAt` (horodatage serveur), `updatedAt` (horodatage serveur). **Nouveaux en v4, tous optionnels :** `status` (voir plus bas), `negotiable` (booléen), `yearBuilt` (nombre, 1800 ou plus), `documentsNote` (chaîne, 200 caractères au maximum), `furnished` (booléen), `depositMonths` (nombre, 0 ou plus), `availableFrom` (horodatage), `minMonths` (nombre, 1 ou plus), `maxGuests` (nombre, 1 ou plus), `beds` (nombre, 0 ou plus), `amenities` (liste, 10 clés au maximum), `checkIn` et `checkOut` (chaîne `HH:mm`), `houseRules` (liste, 4 clés au maximum), `minNights` (nombre, 1 ou plus), `viewCount` (nombre, 0 ou plus), `verified` (booléen) | **Lecture : tout le monde, connecté ou non** (navigation en invité, VST-72). Création : utilisateur connecté avec `ownerId == uid`, `verified` absent ou faux. Modification : le propriétaire seulement ; `ownerId`, `createdAt` et `verified` ne peuvent pas changer. Suppression : le propriétaire seulement. Les champs optionnels doivent avoir le bon type quand ils sont présents. |
| `listings/{id}/photos` | identifiants fixes `p0` à `p9` | `base64` (chaîne, compressée, moins de 200 Ko), `createdAt` (horodatage serveur) | Lecture : tout le monde (navigation en invité). Création, modification, suppression : le propriétaire de l'annonce seulement. Les 10 identifiants fixes imposent le maximum de 10 photos. L'identifiant donne l'ordre d'affichage. Chaque ajout ou suppression est une écriture groupée avec la mise à jour de `photoCount` sur l'annonce. |
| `listings/{id}/contact` | identifiant fixe `info` | `contactPhone` (chaîne, `+216` puis 8 chiffres, premier chiffre 2, 3, 4, 5, 7 ou 9), `whatsappEnabled` (booléen, optionnel), `updatedAt` (horodatage, optionnel). Aucun autre champ. | **Lecture : utilisateurs connectés seulement** (un invité n'obtient jamais le numéro). Création, modification, suppression : le propriétaire de l'annonce seulement. |
| `favorites` | `{uid}_{listingId}` | `userId` (chaîne), `listingId` (chaîne), `createdAt` (horodatage serveur) | Lecture, création, suppression : l'utilisateur seulement. |
| `conversations` | `{listingId}_{buyerId}` | `participantIds` (tableau d'exactement 2 uid), `listingId` (chaîne), `lastMessage` (chaîne), `lastMessageAt` (horodatage serveur), `unread` (table `uid -> nombre`, messages que l'utilisateur n'a pas encore lus ; +1 pour l'autre personne à chaque envoi, remis à 0 quand l'utilisateur ouvre le chat) | Lecture, création, modification : les participants seulement. |
| `conversations/{id}/messages` | identifiant automatique | `senderId` (chaîne), `text` (chaîne), `createdAt` (horodatage serveur) | Lecture : les participants (les règles lisent la conversation parente). Création : un participant avec `senderId == uid`. Ni modification ni suppression. |

## Types d'offre (vue produit, aucun champ stocké)

`sale` (vente) = `listingType` sale. `rent` (location) = `listingType` rent avec `rentPeriod` month ou year. `stay` (séjour) = `listingType` rent avec `rentPeriod` night. Les deux applications utilisent une seule fonction `offerTypeOf(listing)`. Détails : `docs/offer-types.md`.

## Valeurs de `propertyType` (liste finale)

`apartment`, `house`, `villa`, `studio`, `riad`, `guest_house`, `land`, `commercial`

`land` et `commercial` ne sont jamais loués à la nuit (refusé par les règles). La même liste sert partout : modèle de données, règles, filtres et maquettes.

## Valeurs de `status`

| Type d'offre | `status` autorisés |
|---|---|
| vente | `available`, `reserved`, `sold`, `hidden` |
| location | `available`, `reserved`, `rented`, `hidden` |
| séjour | `available`, `unavailable`, `hidden` |

Un `status` absent veut dire `available` pour les **règles**. **Les requêtes ne peuvent pas le faire** : `where status == 'available'` ne renvoie pas les documents sans le champ. Donc **les applications écrivent toujours `status: 'available'` à la création d'une annonce**, et les annonces créées avant la v4 (données de test) doivent recevoir le champ une fois à la main dans la console Firebase. Seul le propriétaire change le `status`.

## Clés des équipements et des règles de la maison

`amenities` : `wifi`, `ac`, `heating`, `kitchen`, `parking`, `pool`, `breakfast`, `washing_machine`, `tv`, `garden`.
`houseRules` : `no_smoking`, `no_pets`, `no_parties`, `quiet_hours`.
Les applications traduisent ces clés (on ne stocke jamais de texte traduit).

## Décisions

- `messages` est une sous-collection de `conversations` (plus simple pour le temps réel et les règles).
- `currency` est une chaîne de 3 lettres remplie depuis la configuration (TND). Les règles vérifient seulement qu'il y a 3 lettres.
- Les photos sont stockées en base64 compressé dans `listings/{id}/photos` avec des identifiants fixes `p0` à `p9`, parce que les règles ne savent pas compter des documents (10 au maximum, relevé de 5 le 12 novembre). Le champ `order` est supprimé : l'identifiant donne l'ordre.
- Les champs de recherche (`listingType`, `rentPeriod`, `propertyType`, `status`, `price`, `city`, `createdAt`) sont des champs de premier niveau de `listings`.
- `latitude`, `longitude`, `bedrooms`, `bathrooms` et `areaSqm` sont optionnels. La carte n'affiche que les annonces qui ont des coordonnées.
- L'identifiant d'une conversation est `{listingId}_{buyerId}` : il y a une conversation par acheteur et par annonce. `participantIds` contient toujours exactement 2 uid.
- Le profil utilisateur a une partie publique (`users/{uid}` : nom et photo, lisible par tout utilisateur connecté, pour afficher les noms et photos dans les annonces et le chat) et une partie privée (`users/{uid}/private/contact` : e-mail et téléphone, lisible seulement par l'utilisateur).
- **Le numéro de téléphone d'une annonce n'est pas stocké dans le document de l'annonce.** Les annonces sont lisibles par les invités : un numéro à l'intérieur serait public. Il est dans `listings/{id}/contact/info`, lisible seulement par les utilisateurs connectés. Les applications ne le lisent que quand l'écran de détails est ouvert par un utilisateur connecté. À la publication, les applications écrivent l'annonce et le contact dans **un seul lot** (batch).
- `photoCount` reste synchronisé avec les photos : ajouter ou supprimer une photo et mettre à jour `photoCount` sur l'annonce se font dans une seule écriture groupée (une écriture atomique, jamais deux séparées).
- `verified` (le badge « Vérifié ») n'est posé que depuis la console Firebase, par Manar. Les règles refusent tout client qui le met à vrai ou le modifie.
- `viewCount` sert au tableau de bord du propriétaire (Sprint 3). Sa règle vérifie seulement le type et le minimum pour l'instant ; la limite « +1 par utilisateur et par jour » viendra avec le ticket du tableau de bord (VST-98).
- Suppression d'une annonce : l'application supprime ses photos et son `contact/info` dans le même lot (sinon ils restent orphelins).
- `createdAt` et `updatedAt` sont des horodatages serveur.

## Index (`firebase/firestore.indexes.json`)

Tous portent sur la collection `listings`, avec `status` en premier, parce que chaque requête publique filtre sur `status == 'available'`.

| Requête | Index |
|---|---|
| Onglet Acheter, trié par prix | `status`, `listingType`, `price` |
| Onglet Acheter, le plus récent d'abord | `status`, `listingType`, `createdAt` (décroissant) |
| Onglet Louer ou Séjourner (filtre sur `rentPeriod`), par prix | `status`, `listingType`, `rentPeriod`, `price` |
| Onglet Louer ou Séjourner, le plus récent d'abord | `status`, `listingType`, `rentPeriod`, `createdAt` (décroissant) |
| Filtre par type de bien | `status`, `propertyType`, `createdAt` (décroissant) |
| Filtre par ville, le plus récent d'abord | `status`, `city`, `createdAt` (décroissant) |
| Filtre par ville, par prix | `status`, `city`, `price` |
| Mes annonces | `ownerId`, `createdAt` (décroissant) |

La liste finale vient des requêtes de recherche (VST-40). Quand Firestore ne sait pas faire une combinaison de filtres, l'application filtre sur le téléphone la petite liste restante.

## Diagrammes

- Diagramme de classes : `docs/c4/level4-classes.png` (source : `docs/c4/level4-classes.mmd`).
- Modèle de données (entités et relations) : `docs/uml/modele-de-donnees.png` (source : `docs/uml/modele-de-donnees.mmd`).
