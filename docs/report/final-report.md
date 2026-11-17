# Vesta : rapport final du mini-projet

Rapport final (VST-57), état de `develop` au 17 novembre 2026. Équipe : Manar Degachi (cheffe de groupe), Eya Ben Belgacem, Ahmed Bouguerra, Mahmoud Saadaoui.

Vesta est une application mobile pour acheter, louer, vendre et séjourner en Tunisie. Elle est construite deux fois, avec Flutter (publiée en test fermé sur Google Play) et avec React Native (version réduite pour la démonstration), sur un seul back-end Firebase, en arabe tunisien, français et anglais.

## 1. Contexte, objectifs et équipe

Vesta répond au sujet « Application mobile services immobilier » de M. Wahid Hamdi (ISET Tozeur). Le rendu est fixé au 24 novembre 2026 à 08:30, avec un gel du code le 17 novembre. L'objectif : une application complète qui couvre trois offres (vente, location, séjour), construite avec deux technologies mobiles pour les comparer, sur un back-end commun.

- **Flutter** est l'application de référence, publiée en test fermé sur Google Play.
- **React Native** (Expo) est une version réduite, présentée en démonstration académique.
- **Firebase** (Authentication et Firestore, offre gratuite) sert aux deux applications.

| Membre | Rôle principal et réalisations |
| --- | --- |
| Manar Degachi | Cheffe de groupe et relectrice. Projet Firebase et règles Firestore, modèle de données, squelette Flutter, thème et design system, chat, carte et géolocalisation (Flutter et React Native), onboarding, paramètres, sécurité des clés API, intégration des pull requests. |
| Eya Ben Belgacem | Annonces Flutter : liste, détails, équipements, recherche et filtres, formulaire de publication, Mes annonces, suppression de compte. Recherche et alertes de messages React Native. Contenu de démonstration et revue des pull requests. |
| Ahmed Bouguerra | Qualité et outils : plan de test, contrôle des couleurs, UI kit Flutter, pipeline de traductions, authentification, navigation et formulaire de publication React Native. |
| Mahmoud Saadaoui | Favoris, profil, boutons Appeler et WhatsApp, tests des règles Firestore, build Android signé pour Google Play. Favoris React Native. Chat et contact React Native (pull requests encore ouvertes). |

## 2. Architecture et choix techniques

Les deux applications ont la même structure de modules (Auth, Recherche, Détails, Publier, Carte, Chat, Favoris, Profil, Notifications) et une seule couche de données devant Firebase. Aucun écran n'appelle Firebase directement : un écran appelle un contrôleur, le contrôleur appelle un dépôt (repository), le dépôt accède à Firestore. Le modèle C4 (niveaux 1 à 4) est dans `docs/c4/`.

| Choix | Décision | Raison |
| --- | --- | --- |
| Back-end | Firebase Authentication et Firestore, offre gratuite (Spark) | Un seul back-end pour les deux applications, sans carte bancaire. |
| Photos | Images compressées en base64 dans `listings/{id}/photos` (10 maximum, identifiants fixes `p0` à `p9`) | Firebase Storage demande l'offre payante. Les règles ne savent pas compter des documents : les identifiants fixes imposent la limite. |
| Carte | OpenStreetMap (flutter\_map, react-native-maps) | Aucune clé ni facturation, contrairement à Google Maps. |
| Notifications | Alertes dans l'application et locales, compteur de messages non lus | Les notifications push serveur (FCM) demandent des Cloud Functions, donc l'offre payante. |
| Offres | Trois offres (vente, location, séjour) déduites de `listingType` et `rentPeriod`, via une seule fonction `offerTypeOf` | Aucun nouveau champ stocké, les annonces anciennes restent valides. |
| Contact | Numéro de téléphone dans un document privé `listings/{id}/contact/info`, lisible seulement par les utilisateurs connectés | Les annonces sont publiques (navigation en invité) : un numéro dans l'annonce serait public. |
| État (Flutter) | Riverpod, go\_router | Contrôleurs testables, navigation déclarative. |
| Langues | Un fichier maître `docs/translations.csv` et un script qui génère les fichiers Flutter (.arb) et React Native (.ts) | Une seule source pour l'arabe tunisien (droite à gauche), le français et l'anglais, vérifiée par la CI. |
| Design | Seules les couleurs du thème Figma (`AppColors`, `theme.ts`), contrôle automatique `check-colors` | Le même rendu dans les deux applications. |

**Sécurité.** Les règles Firestore sont testées avec l'émulateur (`firebase/tests/`). Les annonces sont lisibles par tous, écrites seulement par leur propriétaire ; le badge « vérifié » ne peut pas être mis par un client ; les conversations ne sont lisibles que par leurs deux participants. Les clés API Firebase sont restreintes aux API nécessaires, et les fichiers de configuration privés ne sont jamais dans Git.

## 3. État des fonctionnalités au 17 novembre

L'application Flutter couvre l'ensemble du MVP. L'application React Native est volontairement réduite : elle montre la même architecture et le même design sur les modules les plus visibles. Ce tableau décrit ce qui est dans la branche `develop`, pas ce qui est annoncé dans Jira ; « en revue » veut dire une pull request ouverte, non fusionnée.

| Fonctionnalité | Flutter | React Native |
| --- | --- | --- |
| Inscription, connexion, session conservée, déconnexion | Fait | Fait |
| Navigation en invité (annonces visibles sans compte) | Fait | Non fait |
| Recherche et filtres (ville, prix, type d'offre, type de bien) | Fait | Fait |
| Liste des annonces | Fait | Fait |
| Détails d'une annonce, photos, équipements | Fait | Fait |
| Publier une annonce avec photos | Fait | Fait (équipements, règles, horaires ; testé sur téléphone) |
| Modifier et supprimer une annonce, Mes annonces | Fait | Non fait |
| Statut d'une annonce (disponible, réservé, loué, vendu) | Fait (partie 1) | Non fait |
| Carte et géolocalisation | Fait | Fait |
| Chat entre acheteur et propriétaire | Fait | En revue (#102, non fusionnée) |
| Alertes de messages et badge de messages non lus | Fait | Fait |
| Contact : Appeler et WhatsApp | Fait | En revue (#103, non fusionnée) |
| Favoris | Fait | Écran écrit, onglet encore vide |
| Profil : nom, photo, téléphone, e-mail | Fait | Non fait (onglet vide) |
| Paramètres, choix de la langue, onboarding, centre de notifications | Fait | Langue par défaut seulement |
| Suppression du compte | Fait | Non fait |
| Arabe tunisien (droite à gauche), français, anglais | Fait | Fait |

Prévues au départ puis coupées faute de temps (voir la section 5) : réservations, avis, assistant IA, tableau de bord du propriétaire, signalement et blocage.

## 4. Qualité, tests et publication

Chaque changement passe par une pull request vers `develop`, relue avant d'être fusionnée. Quatre contrôles automatiques tournent à chaque fois : `flutter analyze` (aucune alerte), `flutter test`, le contrôle des couleurs du thème et la vérification des traductions (GitHub Actions). La branche `main` ne reçoit que des fusions de `develop` en fin de sprint.

| Niveau de test | Résultat |
| --- | --- |
| Flutter, tests automatiques | 166 tests réussis le 16 novembre (widgets, contrôleurs, dépôts, localisation) |
| React Native, tests automatiques | `tsc` et `eslint` sans erreur ; 68 tests réussis dans la PR des équipements (#122), à refaire sur `develop` après les dernières fusions |
| Règles Firestore | Tests avec l'émulateur Firebase dans `firebase/tests/` (authentification et règles des annonces, photos, contact, conversations) |
| Plan de test manuel | 60 cas communs aux deux applications, joués sur téléphone réel (`docs/test-plan.md`) ; la partie B est fusionnée (#117) : seuls les cas réellement testés sont en « Pass », les autres restent « Not tested » ; les résultats React Native (#127) sont en relecture |
| Téléphones réels | Samsung de Manar, Redmi d'Eya et téléphones des autres membres, en arabe, français et anglais |

Les tests sur téléphone ont trouvé de vrais défauts, corrigés avant le gel : un prix absurde accepté par le formulaire et par les règles (VST-104), la réinitialisation des filtres de recherche (VST-124), l'icône « œil » du mot de passe (#118).

**Google Play.** La version 1.0.0 (build 1) est publiée en test fermé par Mahmoud depuis un compte développeur. Un identifiant d'application distinct pour le mode debug (`com.vesta.flutterapp.debug`) permet de lancer l'application depuis l'ordinateur sans supprimer la version du Play Store. Les textes de la fiche (courts et longs, en trois langues) et les visuels sont dans `docs/store/` (pull request #107) et `docs/brand/`. L'application est un projet académique : elle n'est pas publiée en production.

**Contenu.** Les 15 annonces visibles (5 séjours, 5 locations, 5 ventes) sont marquées « Démo » dans le titre et n'ont pas de badge « vérifié ». Elles utilisent des informations et des photos réelles, avec l'accord oral par téléphone des propriétaires, pour un usage académique seulement ; ils ont demandé à ne pas être nommés. Eya a recueilli ces accords le 17 novembre et ils sont notés dans `docs/content/sources.md`. Nous n'avons aucun accord écrit : un lancement réel demanderait l'accord écrit de chaque propriétaire.

## 5. Limites connues et travaux futurs

La plupart des limites viennent d'un choix : rester sur l'offre gratuite de Firebase, sans Cloud Functions ni Storage. Le détail complet est dans `docs/report/limits-and-future-work.md`.

**Limites connues**

- **Photos :** stockées en base64 dans Firestore (10 par annonce, environ 800 px). Le choix de photos fonctionne sur téléphone, pas dans Chrome : Vesta cible Android.
- **Recherche :** elle lit les 100 annonces les plus récentes et filtre dans l'application, sans pagination.
- **Hors ligne :** une annonce publiée sans internet reste en attente et part plus tard ; la bannière hors ligne ne détecte pas la connexion.
- **Contact :** le numéro du propriétaire est lisible par tout compte connecté, y compris un compte Firebase anonyme. La règle qui l'interdit n'est pas fusionnée.
- **Comptes :** la suppression d'un compte garde les messages du chat pour l'autre personne ; le signalement et le blocage ne sont pas faits ; il n'y a pas de Cloud Functions pour nettoyer côté serveur.
- **Langues :** une relecture native de l'arabe et du français, et une vérification de la mise en page de droite à gauche sur plus d'appareils, n'ont pas été terminées. Les noms saisis par les utilisateurs ne sont pas translittérés.
- **React Native :** version réduite (voir le tableau de la section 3). Le chat (#102) et le contact (#103) restent dans des pull requests ouvertes, non fusionnées avant le gel du code et non testées sur deux téléphones. Les onglets Favoris et Profil sont vides.
- **Contenu :** annonces réelles de démonstration, avec accord oral seulement (pas d'accord écrit).

**Travaux futurs, par ordre de valeur**

1. Notifications push réelles (FCM) et Firebase Storage pour les photos, avec l'offre payante.
2. Règle `notAnonymous()` pour protéger le numéro de contact, avec ses tests d'émulateur.
3. Recherche côté serveur avec filtres et pagination, et annonces séparées par type (ventes, locations, séjours) comme l'a suggéré notre professeur.
4. Réservations, avis, assistant IA et tableau de bord du propriétaire, dans les deux applications.
5. Statut des annonces, partie 2 (VST-136) : rubans de couleur, statut « masqué » visible seulement par le propriétaire, nombre de favoris sur les cartes.
6. Synchroniser l'e-mail du profil dans `private/contact` après un changement, connexion avec Google et Apple, signalement et blocage.
7. Mode sombre, détection hors ligne avant la publication, relecture native de l'arabe, plus de tests sur téléphones réels.

## 6. Organisation, difficultés et conclusion

**Organisation.** Le travail est suivi dans Jira (projet VST) par sprints, avec deux démonstrations internes avant le rendu. Chaque tâche a une branche `feature/VST-NN-nom`, une pull request vers `develop`, un message de commit `type(scope): message [VST-NN]` et une relecture par une personne autre que l'auteur. La cheffe de groupe fusionne après test sur téléphone. Chaque membre a écrit un document de passation (`docs/handover/`) ; une fiche de questions-réponses sur le module d'un autre membre a été préparée pour chacun, afin que chacun puisse expliquer tout le projet.

| Chiffre | Valeur au 17 novembre |
| --- | --- |
| Commits sur `develop` | environ 400 |
| Pull requests fusionnées | plus de 100 |
| Code Flutter (Dart, hors fichiers générés) | environ 10 800 lignes |
| Code React Native (TypeScript) | environ 4 700 lignes |
| Langues | 3 (arabe tunisien, français, anglais) |

**Difficultés rencontrées et ce que nous en avons retenu**

- **L'offre gratuite de Firebase** nous a obligés à inventer des contournements (photos en base64, alertes locales). Nous avons noté chaque contournement comme une limite, pas comme une réussite.
- **La clé API Android restreinte** (sécurité) a bloqué la connexion sur une version signée avec une clé non listée : l'application affichait une erreur générique. Chaque clé de signature, y compris celle de Google Play, a besoin de sa ligne dans la restriction. Pour la démo et les tests, la restriction d'application est actuellement sur « Aucune » ; elle sera remise après les tests.
- **Les traductions générées** créaient des conflits à chaque fusion. Le fichier maître et le script, avec une vérification en CI, ont réglé le problème.
- **Expo Go** impose la version exacte du SDK : l'application React Native ne se lance que sur un téléphone avec la bonne version d'Expo Go.
- **Le contenu réel** : sans accord écrit des propriétaires, nous avons choisi des annonces de démonstration plutôt que de publier de vraies annonces sans autorisation.
- **Le temps** : réservations, avis, assistant IA et tableau de bord ont été coupés avant le gel du code pour finir, tester et corriger ce qui existe. Une fonctionnalité plus petite mais testée sur téléphone vaut mieux qu'une grande qui plante.

**Conclusion.** Vesta fonctionne de bout en bout dans sa version Flutter : on crée un compte ou on navigue en invité, on cherche, on voit les annonces sur une liste et sur une carte, on contacte un propriétaire par chat, appel ou WhatsApp, on publie et on gère ses annonces, dans trois langues dont l'arabe de droite à gauche. La version React Native montre la même architecture sur un périmètre plus petit. Les limites sont connues, documentées et alignées avec le plan de travaux futurs.
