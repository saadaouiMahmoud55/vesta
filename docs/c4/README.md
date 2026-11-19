# Diagrammes C4 de Vesta

Le modèle C4 décrit l'architecture en quatre niveaux, du plus général au plus détaillé : contexte, conteneurs, composants, classes. Tous les diagrammes sont en français. Les noms des classes et des composants restent ceux du code.

| Niveau | Fichier | Contenu |
|---|---|---|
| 1 | `level1-context.png` et `Vesta_C4_Niveau1_Contexte.pdf` (source : `level1-context.mmd`) | Contexte : qui utilise Vesta et avec quels systèmes externes elle communique |
| 2 | `level2-containers.png` et `Vesta_C4_Niveau2_Containers.pdf` (source : `level2-containers.mmd`) | Conteneurs : les deux applications, Firebase, OpenStreetMap |
| 3 | `level3-auth-profile.png` (source : `level3-auth-profile.mmd`) | Composants Auth et Profil de l'application Flutter (VST-27) |
| 3 | `level3-listings-favorites.png` (source : `level3-listings-favorites.mmd`) | Composants Annonces et Favoris de l'application Flutter (VST-28) |
| 3 | `level3-search-map-chat.png` (source : `level3-search-map-chat.mmd`) | Composants Recherche, Carte et Chat de l'application Flutter (VST-29) |
| 4 | `level4-classes.png` (source : `level4-classes.mmd`) | Classes de données (voir `docs/data-model.md`) |

D'autres diagrammes UML (cas d'utilisation, séquences, modèle de données, planning) sont dans `docs/uml/`.

Les sources sont des fichiers Mermaid. Pour redessiner un PNG : `npx -p @mermaid-js/mermaid-cli mmdc -i level3-auth-profile.mmd -o level3-auth-profile.png -s 2 -b white`, ou coller le fichier `.mmd` sur https://mermaid.live et exporter le PNG.

## Niveau 1 : contexte

Question : qui utilise Vesta, et avec quels systèmes extérieurs communique-t-elle ? Le diagramme montre Vesta comme une seule boîte, les deux types d'utilisateurs (acheteur, locataire ou voyageur ; propriétaire ou agent) et les services dont elle dépend : Firebase (authentification et base de données), OpenStreetMap (tuiles de la carte) et Google Play (distribution). Il ne contient aucun détail technique.

## Niveau 2 : conteneurs

Question : quelles sont les grandes parties de Vesta et comment communiquent-elles ? Un conteneur est une partie qui s'exécute seule : une application, une base de données, un service (rien à voir avec Docker). Vesta existe en deux versions, Flutter (Dart, Android) et React Native (TypeScript, démonstration académique), qui utilisent le même back-end Firebase (Authentication et Firestore). Choix : pas de Firebase Storage (les photos sont en base64 dans Firestore), pas de notifications push FCM dans le MVP, OpenStreetMap au lieu de Google Maps.

## Niveau 3 : Auth et Profil

Comment lire le diagramme :

- Le grand cadre en pointillés est l'application Flutter. Les écrans sont en haut, puis les contrôleurs, puis les dépôts (repositories). Les services Firebase sont en dehors du cadre.
- Chaque boîte indique son type entre crochets : `[Composant : écran Flutter]`, `[Composant : contrôleur Riverpod]`, `[Composant : dépôt (repository)]`, `[Système externe]`. Une petite légende en bas explique les couleurs.
- Les flèches montrent qui appelle qui. La règle est Écran -> Contrôleur -> Dépôt -> Firebase. Un écran ne parle jamais directement à Firebase.
- Les noms des composants sont ceux du code. L'application React Native utilise les mêmes noms et les mêmes couches (ses contrôleurs sont des hooks ou des contextes).
- Les noms de données viennent du modèle de données (`docs/data-model.md`, VST-30) : `users/{uid}` (profil public) et `users/{uid}/private/contact` (e-mail et téléphone).
- `PhotoService` s'exécute sur le téléphone, avant tout envoi : `EditProfileScreen` l'utilise pour choisir une photo de profil et l'enregistrer en JPEG de moins de 200 Ko (`photoBase64`). C'est le même outil que dans le diagramme des annonces.
- Un croisement de flèches reste volontairement : les deux contrôleurs utilisent les deux dépôts (`AuthController` et `ProfileController` appellent `AuthRepository` et `UserRepository`), donc on ne peut pas tout tracer sans croisement en gardant les couches.

| Composant | Type | Responsabilité |
|---|---|---|
| `LoginScreen` | écran Flutter | Formulaire e-mail et mot de passe. |
| `SignUpScreen` | écran Flutter | Formulaire nom, e-mail et mot de passe. |
| `ProfileScreen` | écran Flutter | Affiche le profil, le choix de la langue et le bouton de déconnexion. |
| `EditProfileScreen` | écran Flutter | Formulaire pour changer le nom, la photo et le téléphone. |
| `PhotoService` | outil côté téléphone | Choisit une photo, la réduit et l'enregistre en JPEG de moins de 200 Ko (`photoBase64`). |
| `AuthController` | contrôleur Riverpod | Garde l'état de connexion, contrôle les champs, gère l'inscription, la connexion et la déconnexion, et demande à `UserRepository` de créer le profil après l'inscription. |
| `ProfileController` | contrôleur Riverpod | Charge et enregistre le profil, gère les états de chargement et d'erreur, obtient l'identifiant de l'utilisateur depuis `AuthRepository`. |
| `AuthRepository` | dépôt | Enveloppe Firebase Auth : inscription, connexion, déconnexion, session. |
| `UserRepository` | dépôt | Lit et écrit `users/{uid}` et `users/{uid}/private/contact` dans Firestore. |

## Niveau 3 : Annonces et Favoris

Même lecture que pour le diagramme Auth et Profil (types entre crochets, légende en bas, Écran -> Contrôleur -> Dépôt -> Firebase). Les noms de données viennent de `docs/data-model.md` : `listings`, `listings/{id}/photos` et `favorites`. Les noms du flux de publication suivent le code Flutter fusionné dans VST-38.

- Les photos sont stockées dans Firestore (base64 compressé dans `listings/{id}/photos`), PAS dans Firebase Storage (décision du 8 octobre : Storage demande une offre payante).
- `PhotoService` s'exécute sur le téléphone, avant tout envoi : il choisit une photo, la réduit à environ 800 px de large, l'enregistre en JPEG de moins de 200 Ko et refuse une 11e photo.
- `ListingRepository` écrit l'annonce, ses photos (identifiants fixes `p0` à `p9`) et `photoCount` dans une seule écriture groupée : il n'y a donc pas de dépôt séparé pour les photos.
- `formatPrice` (TND, séparateurs de milliers) et la couche de traduction (anglais, français, arabe) sont des outils partagés utilisés par chaque écran. Ils sont dessinés une seule fois, sans flèches, pour garder le diagramme lisible.
- `FavoritesController` demande à `ListingRepository` les annonces favorites, parce qu'un favori ne stocke que l'identifiant de l'annonce.
- L'écran de liste s'appelle `ListingsScreen`, le nom utilisé dans le code.

| Composant | Type | Responsabilité |
|---|---|---|
| `PublishListingScreen` | écran Flutter | Formulaire de publication d'une annonce (prix en TND, période de location, type de bien, ville) avec photos. |
| `ListingsScreen` | écran Flutter | Liste les annonces avec photo et prix. |
| `ListingDetailScreen` | écran Flutter | Affiche une annonce, ses photos et un bouton favori. |
| `FavoritesScreen` | écran Flutter | Liste les annonces favorites. |
| `ListingController` | contrôleur Riverpod | Gère la publication, charge les annonces, gère les états de chargement et d'erreur. |
| `FavoritesController` | contrôleur Riverpod | Ajoute, retire et charge les favoris. |
| `ListingRepository` | dépôt | Lit et écrit la collection `listings` et la sous-collection `listings/{id}/photos` (écriture groupée). |
| `FavoritesRepository` | dépôt | Lit et écrit la collection `favorites`. |
| `PhotoService` | outil côté téléphone | Choisit une photo, la réduit à environ 800 px de large, JPEG de moins de 200 Ko, 10 photos au maximum. |
| `formatPrice` et couche de traduction | outil partagé | Même format de prix et mêmes textes dans chaque écran. |

## Niveau 3 : Recherche, Carte et Chat

Même lecture que les autres diagrammes de niveau 3 (types entre crochets, légende en bas, Écran -> Contrôleur -> Dépôt -> Firebase). Les trois modules sont regroupés chacun dans un cadre. Les noms de données viennent de `docs/data-model.md` : `listings`, `conversations` et `conversations/{id}/messages`.

- La carte utilise les tuiles OpenStreetMap, PAS Google Maps (décision du 8 octobre). `MapScreen` charge les tuiles directement depuis OpenStreetMap (la règle « ne jamais parler à Firebase directement » concerne Firebase) et affiche l'attribution `© contributeurs OpenStreetMap`.
- La carte n'affiche que les annonces qui ont `latitude` et `longitude` (optionnelles dans le modèle de données). Le centre par défaut de la carte (Tunis) vient de la configuration.
- `LocationService` demande la permission GPS et obtient la position du téléphone. `MapController` est le seul appelant.
- Le contrôleur s'appelle `SearchFiltersController` (et non `SearchController`) parce que Flutter Material a déjà une classe `SearchController` : le nom entrerait en conflit dans le code.
- `SearchFilters` (fourchette de prix, lieu, type de bien, vente ou location) est un widget utilisé par `SearchScreen`. `SearchFiltersController` garde les filtres et interroge `ListingRepository`, partagé avec la carte et avec le module Annonces.
- L'identifiant d'une conversation est `{listingId}_{buyerId}` et ses messages sont une sous-collection. `ChatController` sert les deux écrans du chat à travers `ChatRepository`.
- Alerte de nouveau message (MVP) : il n'y a pas de push serveur, parce que les Cloud Functions ne sont pas disponibles dans l'offre gratuite de Firebase. `ChatRepository` écoute Firestore en temps réel et `ChatController` fournit le nombre de messages non lus. L'utilisateur voit un badge sur l'icône de notifications et, dans `NotificationsScreen` (le centre de notifications, VST-99), une « notification » est une conversation qui contient des messages non lus.
- Hors MVP : les notifications locales et le vrai push FCM (application fermée). Il demande l'offre Blaze de Firebase ou un petit serveur externe. C'est un ticket futur (voir « Travaux futurs » ci-dessous).
- `formatPrice`, la configuration et la couche de traduction sont des outils partagés utilisés par les écrans. Ils sont dessinés une seule fois, sans flèches.

| Composant | Type | Responsabilité |
|---|---|---|
| `SearchScreen` | écran Flutter | Champ de recherche et liste des résultats. |
| `SearchFilters` | widget Flutter | Fourchette de prix, lieu, type de bien, vente ou location. |
| `SearchFiltersController` | contrôleur Riverpod | Garde les filtres et charge les résultats. |
| `MapScreen` | écran Flutter | Carte avec les annonces, affiche l'attribution OpenStreetMap. |
| `MapController` | contrôleur Riverpod | Charge les annonces avec coordonnées et la position de l'utilisateur. |
| `LocationService` | service côté téléphone | Demande la permission GPS et obtient la position. |
| `ChatListScreen` | écran Flutter | Liste mes conversations. |
| `ChatScreen` | écran Flutter | Messages d'une conversation. |
| `ChatController` | contrôleur Riverpod | Charge les conversations et les messages, envoie un message et fournit le nombre de messages non lus. |
| `ChatRepository` | dépôt | Lit et écrit `conversations` et `conversations/{id}/messages`, et écoute Firestore en temps réel. |
| `NotificationsScreen` | écran Flutter | Centre de notifications (VST-99) : liste les conversations qui ont des messages non lus, et le badge de la barre du haut. |
| `ListingRepository` | dépôt | Lit la collection `listings` (recherche et carte). |
| `formatPrice`, configuration, couche de traduction | outil partagé | Même format de prix, même centre de carte et mêmes textes dans chaque écran. |

### Travaux futurs

- Notifications locales et vraies notifications push avec FCM, pour que l'alerte arrive aussi quand l'application est fermée. FCM est gratuit, mais envoyer un push à un autre utilisateur demande un serveur : l'offre Blaze de Firebase (Cloud Functions) ou un petit serveur externe. Hors MVP, à créer comme ticket Jira.
