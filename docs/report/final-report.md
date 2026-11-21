# Vesta : rapport final du mini-projet

**Institut Supérieur des Études Technologiques de Tozeur**
Mini-projet : application mobile de services immobiliers, année universitaire 2026-2027
Encadrant : M. Wahid Hamdi
Équipe : Manar Degachi (cheffe de groupe), Eya Ben Belgacem, Ahmed Bouguerra, Mahmoud Saadaoui
Remise : 24 novembre 2026

## Sommaire

1. Contexte, objectifs et équipe
2. Architecture et choix techniques
3. État des fonctionnalités
4. Qualité, tests et publication
5. Limites connues et travaux futurs
6. Organisation, difficultés et conclusion
7. Annexe A : cahier des charges
8. Annexe B : technologies et outils
9. Annexe C : diagrammes de conception
10. Annexe D : glossaire
11. Annexe E : webographie

Rapport final (VST-57), état de `develop` au 19 novembre 2026. Équipe : Manar Degachi (cheffe de groupe), Eya Ben Belgacem, Ahmed Bouguerra, Mahmoud Saadaoui.

Vesta est une application mobile pour acheter, louer, vendre et séjourner en Tunisie. Elle est construite deux fois, avec Flutter (sur Google Play : test interne, test fermé, puis production publiée le 19 novembre) et avec React Native (version réduite pour la démonstration), sur un seul back-end Firebase, en arabe tunisien, français et anglais.

## 1. Contexte, objectifs et équipe

Vesta répond au sujet « Application mobile services immobilier » de M. Wahid Hamdi (ISET Tozeur). Le rendu est fixé au 24 novembre 2026 à 08:30, avec un gel du code le 18 novembre à 22 h. Après le gel, seuls le numéro de version (#139), des traductions (#140 et deux commits de traduction) et de la documentation (#127, #133) ont été fusionnés, jusqu'à minuit. L'objectif : une application complète qui couvre trois offres (vente, location, séjour), construite avec deux technologies mobiles pour les comparer, sur un back-end commun.

- **Flutter** est l'application de référence, sur Google Play (test interne et test fermé ; la version 1.0.0 build 3 est publiée le 19 novembre).
- **React Native** (Expo) est une version réduite, présentée en démonstration académique.
- **Firebase** (Authentication et Firestore, offre gratuite) sert aux deux applications.

| Membre | Rôle principal et réalisations |
| --- | --- |
| Manar Degachi | Cheffe de groupe et relectrice. Projet Firebase et règles Firestore, modèle de données, squelette Flutter, thème et design system, chat, carte et géolocalisation (Flutter et React Native), onboarding, paramètres, sécurité des clés API, intégration des pull requests. |
| Eya Ben Belgacem | Annonces Flutter : liste, détails, équipements, recherche et filtres, formulaire de publication, Mes annonces, suppression de compte. Recherche et alertes de messages React Native. Contenu de démonstration et revue des pull requests. |
| Ahmed Bouguerra | Qualité et outils : plan de test, contrôle des couleurs, UI kit Flutter, pipeline de traductions, authentification, navigation et formulaire de publication React Native. |
| Mahmoud Saadaoui | Favoris, profil, boutons Appeler et WhatsApp, tests des règles Firestore, build Android signé pour Google Play. Favoris React Native. Chat React Native et contact React Native (Appeler et WhatsApp), tous deux fusionnés. |

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

**Sécurité.** Les règles Firestore sont testées avec l'émulateur (`firebase/tests/`). Les annonces sont lisibles par tous, écrites seulement par leur propriétaire ; le badge « vérifié » ne peut pas être mis par un client ; les conversations ne sont lisibles que par leurs deux participants. Les clés API Firebase sont restreintes aux API nécessaires ; la restriction d'application de la clé Android est volontairement désactivée (voir les limites). Les fichiers de configuration privés ne sont jamais dans Git.

## 3. État des fonctionnalités au 18 novembre

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
| Chat entre acheteur et propriétaire | Fait | Fait (#102 fusionnée le 18 novembre ; accès par un bouton « Messages » de l'accueil) |
| Alertes de messages et badge de messages non lus | Fait | Fait |
| Contact : Appeler et WhatsApp | Fait | Fait (#103 fusionnée ; tests sur téléphone dans VST-59) |
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
| Flutter, tests automatiques | 174 tests réussis sur `develop` le 18 novembre, `flutter analyze` sans alerte (widgets, contrôleurs, dépôts, localisation) |
| React Native, tests automatiques | `tsc` et `eslint` sans erreur ; 116 tests réussis sur `develop` après les fusions du 18 et du 19 novembre (#102, #103, #131) |
| Règles Firestore | Tests avec l'émulateur Firebase dans `firebase/tests/` (authentification et règles des annonces, photos, contact, conversations) |
| Plan de test manuel | 60 cas communs aux deux applications, joués sur téléphone réel (`docs/test-plan.md`) ; la partie B est fusionnée (#117) : seuls les cas réellement testés sont en « Pass », les autres restent « Not tested » ; les résultats React Native (#127) sont fusionnés |
| Téléphones réels | Samsung de Manar, Redmi d'Eya et téléphones des autres membres, en arabe, français et anglais |

Les tests sur téléphone ont trouvé de vrais défauts, corrigés avant le gel : un prix absurde accepté par le formulaire et par les règles (VST-104), la réinitialisation des filtres de recherche (VST-124), l'icône « œil » du mot de passe (#118).

**Google Play.** La version 1.0.0 (build 1) est disponible en test interne depuis le 22 octobre, et le build 2 en test fermé (Alpha) depuis le 3 novembre (publiés par Mahmoud depuis un compte développeur). Le build 3 (1.0.0+3, signé avec la clé d'envoi) a été envoyé en production et publié le 19 novembre 2026 (Tunisie, politique de confidentialité, page de suppression de compte, section « Sécurité des données » alignée sur le code, compte relecteur). La fiche Google Play est disponible avec le bouton Installer. Un identifiant d'application distinct pour le mode debug (`com.vesta.flutterapp.debug`) permet de lancer l'application depuis l'ordinateur sans supprimer la version du Play Store. Les textes de la fiche (courts et longs, en trois langues) et les visuels sont dans `docs/store/` (pull request #107) et `docs/brand/`. La démonstration s'appuie sur l'application installée sur deux téléphones ; le lien du test fermé reste le plan B.

**Contenu.** Les 15 annonces visibles (5 séjours, 7 locations, 3 ventes) sont marquées « Démo » dans le titre et n'ont pas de badge « vérifié ». Elles utilisent des informations et des photos réelles, avec l'accord oral par téléphone des propriétaires, pour un usage académique seulement ; ils ont demandé à ne pas être nommés. Eya a recueilli ces accords par téléphone et ils sont notés dans `docs/content/sources.md`. Nous n'avons aucun accord écrit : un lancement réel demanderait l'accord écrit de chaque propriétaire.

## 5. Limites connues et travaux futurs

La plupart des limites viennent d'un choix : rester sur l'offre gratuite de Firebase, sans Cloud Functions ni Storage. Le détail complet est dans `docs/report/limits-and-future-work.md`.

**Limites connues**

- **Photos :** stockées en base64 dans Firestore (10 par annonce, environ 800 px). Le choix de photos fonctionne sur téléphone, pas dans Chrome : Vesta cible Android.
- **Recherche :** elle lit les 100 annonces les plus récentes et filtre dans l'application, sans pagination.
- **Hors ligne :** une annonce publiée sans internet reste en attente et part plus tard ; la bannière hors ligne ne détecte pas la connexion.
- **Contact :** le numéro du propriétaire est lisible par tout compte connecté, y compris un compte Firebase anonyme. La règle qui l'interdit n'est pas fusionnée.
- **Comptes :** la suppression d'un compte garde les messages du chat pour l'autre personne ; le signalement et le blocage ne sont pas faits ; il n'y a pas de Cloud Functions pour nettoyer côté serveur.
- **Langues :** une relecture native de l'arabe et du français, et une vérification de la mise en page de droite à gauche sur plus d'appareils, n'ont pas été terminées. Les noms saisis par les utilisateurs ne sont pas translittérés.
- **React Native :** version réduite (voir le tableau de la section 3). Le chat (#102) et le contact (#103, boutons Appeler et WhatsApp dans le détail d'une annonce) sont fusionnés ; les résultats des tests sur téléphone sont dans le ticket VST-59 (tests finaux). Le bouton « Se connecter » du composant de contact ne fait rien, car l'écran de détails React Native n'est accessible que connecté. Les onglets Favoris et Profil sont vides.
- **Contenu :** annonces réelles de démonstration, avec accord oral seulement (pas d'accord écrit).
- **Validation de la description (VST-137) :** les deux applications vérifient seulement que la description n'est pas vide ; le minimum de 40 caractères écrit dans le plan de test (cas LST-05) n'est pas appliqué. Le cas reste en échec côté React Native. Travail futur.

**Travaux futurs, par ordre de valeur**

1. Notifications push réelles (FCM) et Firebase Storage pour les photos, avec l'offre payante.
2. Règle `notAnonymous()` pour protéger le numéro de contact, avec ses tests d'émulateur.
3. Recherche côté serveur avec filtres et pagination, et annonces séparées par type (ventes, locations, séjours) comme l'a suggéré notre professeur.
4. Réservations, avis, assistant IA et tableau de bord du propriétaire, dans les deux applications. La réservation Flutter est en partie faite sur une branche non fusionnée (VST-92) : calcul des nuits et du prix avec tests, textes en trois langues et écran de demande ; il manque la structure `bookings` et `blockedNights` et les règles Firestore.
5. Statut des annonces, partie 2 (VST-136) : rubans de couleur, statut « masqué » visible seulement par le propriétaire, nombre de favoris sur les cartes.
6. Synchroniser l'e-mail du profil dans `private/contact` dès le changement (aujourd'hui, il est mis à jour à la prochaine sauvegarde du profil avec le téléphone), connexion avec Google et Apple, signalement et blocage.
7. Mode sombre, détection hors ligne avant la publication, relecture native de l'arabe, plus de tests sur téléphones réels.

## 6. Organisation, difficultés et conclusion

**Organisation.** Le travail est suivi dans Jira (projet VST) par sprints, avec deux démonstrations internes avant le rendu. Chaque tâche a une branche `feature/VST-NN-nom`, une pull request vers `develop`, un message de commit `type(scope): message [VST-NN]` et une relecture par une personne autre que l'auteur. La cheffe de groupe fusionne après test sur téléphone. Chaque membre a écrit un document de passation (`docs/handover/`) ; une fiche de questions-réponses sur le module d'un autre membre a été préparée pour chacun, afin que chacun puisse expliquer tout le projet.

| Chiffre | Valeur au 18 novembre |
| --- | --- |
| Commits sur `develop` | plus de 450 |
| Pull requests fusionnées | plus de 100 |
| Code Flutter (Dart, hors fichiers générés) | environ 10 800 lignes |
| Code React Native (TypeScript) | environ 4 700 lignes |
| Langues | 3 (arabe tunisien, français, anglais) |

**Difficultés rencontrées et ce que nous en avons retenu**

- **L'offre gratuite de Firebase** nous a obligés à inventer des contournements (photos en base64, alertes locales). Nous avons noté chaque contournement comme une limite, pas comme une réussite.
- **La clé API Android restreinte** (sécurité) a bloqué la connexion sur une version signée avec une clé non listée : l'application affichait une erreur générique. Chaque clé de signature, y compris celle de Google Play, a besoin de sa ligne dans la restriction. Nous avons donc laissé la restriction d'application sur « Aucune » (décision du 21 novembre) : une clé Firebase n'est pas un secret et la protection des données repose sur l'authentification et les règles Firestore ; le risque restant est l'usage du quota par une autre application. La restriction reste un travail futur.
- **Les traductions générées** créaient des conflits à chaque fusion. Le fichier maître et le script, avec une vérification en CI, ont réglé le problème.
- **Expo Go** impose la version exacte du SDK : l'application React Native ne se lance que sur un téléphone avec la bonne version d'Expo Go.
- **Le contenu réel** : sans accord écrit des propriétaires, nous avons choisi des annonces de démonstration plutôt que de publier de vraies annonces sans autorisation.
- **Le temps** : réservations, avis, assistant IA et tableau de bord ont été coupés avant le gel du code pour finir, tester et corriger ce qui existe. Une fonctionnalité plus petite mais testée sur téléphone vaut mieux qu'une grande qui plante.

**Conclusion.** Vesta fonctionne de bout en bout dans sa version Flutter : on crée un compte ou on navigue en invité, on cherche, on voit les annonces sur une liste et sur une carte, on contacte un propriétaire par chat, appel ou WhatsApp, on publie et on gère ses annonces, dans trois langues dont l'arabe de droite à gauche. La version React Native montre la même architecture sur un périmètre plus petit. Les limites sont connues, documentées et alignées avec le plan de travaux futurs.

## Annexe A : cahier des charges

Les histoires d'utilisateur complètes sont dans `docs/user-stories.md` (en anglais) ; le tableau suivant les résume.

**Exigences fonctionnelles**

| Domaine | Exigence |
| --- | --- |
| Authentification | Créer un compte, se connecter, rester connecté, se déconnecter, naviguer en invité |
| Recherche | Chercher et filtrer par type d'offre, ville, prix et type de bien |
| Annonces | Voir les détails, les photos et les équipements ; publier, modifier et supprimer sa propre annonce ; changer son statut |
| Carte | Voir les annonces sur une carte (OpenStreetMap) et se localiser |
| Contact | Écrire au propriétaire par chat, l'appeler ou lui écrire sur WhatsApp |
| Favoris | Garder des annonces en favori et les retrouver |
| Profil | Modifier son nom, sa photo, son téléphone et son e-mail ; voir ses annonces ; supprimer son compte |
| Alertes | Recevoir une alerte dans l'application pour un nouveau message, avec un compteur de messages non lus |
| Offres | Trois types d'offre : vente, location, séjour, avec leurs propres champs |

**Exigences non fonctionnelles**

| Exigence | Réalisation |
| --- | --- |
| Langues et sens de lecture | Arabe tunisien (droite à gauche), français, anglais |
| Coût | Offre gratuite de Firebase, sans Cloud Functions ni Storage |
| Cohérence visuelle | Palette unique contrôlée automatiquement (`check-colors`) |
| Qualité | Analyse statique, tests automatiques, plan de test manuel de 60 cas |
| Sécurité | Règles Firestore testées avec l'émulateur, clés API restreintes, aucun secret dans Git |
| Maintenabilité | Architecture en couches (écran, contrôleur, dépôt, Firebase), identique dans les deux applications |

## Annexe B : technologies et outils

| Rôle | Outil |
| --- | --- |
| Application principale | Flutter et Dart, Riverpod (état), go\_router (navigation) |
| Application de démonstration | React Native avec Expo, TypeScript |
| Back-end | Firebase Authentication et Cloud Firestore |
| Carte | OpenStreetMap (flutter\_map pour Flutter, react-native-maps pour React Native) |
| Traductions | Fichier maître `docs/translations.csv` et script de génération |
| Gestion de projet | Jira (méthode Scrum, sprints), GitHub (branches, pull requests) |
| Intégration continue | GitHub Actions : contrôle des couleurs et des traductions |
| Diagrammes | Mermaid (sources `.mmd` dans le dépôt) |
| Publication | Google Play Console |

## Annexe C : diagrammes de conception

Les diagrammes sont dans le dépôt, en français, avec leurs sources Mermaid :
- **Modèle C4** (niveaux 1 à 4 : contexte, conteneurs, composants, classes) : `docs/c4/`.
- **UML et schémas** : `docs/uml/` (cas d'utilisation, séquences de connexion, de publication et d'envoi de message, modèle de données Firestore, architecture en couches, flux Git et CI, planning).

Ces diagrammes viennent de la pull request #135, fusionnée dans `develop`.

## Annexe D : glossaire

| Terme | Définition |
| --- | --- |
| Firestore | Base de données de documents en temps réel de Firebase |
| Règles Firestore | Règles qui décident qui peut lire ou écrire chaque document |
| Base64 | Codage d'une image en texte, utilisé ici pour stocker les photos dans Firestore |
| Riverpod | Bibliothèque Flutter de gestion d'état |
| RTL | « Right to left » : mise en page de droite à gauche, pour l'arabe |
| Pull request | Demande de fusion d'une branche, relue avant d'entrer dans `develop` |
| Scrum, sprint | Méthode de travail par périodes courtes d'environ deux semaines |
| CI | Intégration continue : contrôles automatiques à chaque pull request |
| FCM | Firebase Cloud Messaging, service de notifications push (non utilisé : offre gratuite) |
| AAB | Android App Bundle, le format envoyé à Google Play |

## Annexe E : webographie

- Flutter : <https://docs.flutter.dev>
- Riverpod : <https://riverpod.dev>
- React Native : <https://reactnative.dev>
- Expo : <https://docs.expo.dev>
- Firebase (Authentication, Firestore et règles) : <https://firebase.google.com/docs>
- OpenStreetMap : <https://www.openstreetmap.org>
- Mermaid : <https://mermaid.js.org>
- Guide Scrum : <https://scrumguides.org>
- Google Play Console : <https://support.google.com/googleplay/android-developer>
