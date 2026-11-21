# Rapport Vesta : limites et travaux futurs

Brouillon pour le rapport final (VST-57). Rédigé le 14 nov. 2026 à partir de ce que nous avons trouvé dans les tests sur téléphone et les revues. Vérifier chaque ligne avec l'état final de `develop` avant de rendre le rapport.

## Limites connues

**Photos**

- Les photos sont stockées en texte base64 compressé dans Firestore, et non dans Firebase Storage (offre gratuite). Maximum 10 par annonce, environ 800 px de large, chacune sous environ 270 000 caractères.
- Le choix de photos fonctionne sur téléphone. Il ne fonctionne pas dans Chrome : le compresseur d'images lit un chemin de fichier, alors que le navigateur fournit une URL blob. Vesta cible les téléphones Android, donc la version web n'est pas prise en charge.

**Hors ligne**

- Une annonce publiée sans internet reste en attente et peut être publiée plus tard, sans que l'utilisateur le sache. La bannière hors ligne n'affiche qu'un message ; elle ne détecte pas la connexion.

**Recherche et annonces**

- La recherche lit les 100 annonces les plus récentes et les filtre dans l'application (pas de filtres côté serveur, pas de pagination).
- Une annonce masquée peut toujours être ouverte par son lien direct.
- **Description (VST-137) :** les deux applications vérifient seulement que la description n'est pas vide ; le minimum de 40 caractères du plan de test (cas LST-05) n'est pas appliqué, et le cas reste en échec côté React Native. Travail futur.
- En mode modification, le propriétaire ne peut pas changer le type d'offre (vente ou location) ni la période de location, car les statuts autorisés en dépendent.

**Langue**

- Les noms saisis par les utilisateurs (nom du profil) restent dans les lettres saisies. L'application ne translittère pas entre l'alphabet latin et l'arabe.
- Une relecture des textes arabes et français par des locuteurs natifs, et une vérification de l'affichage de droite à gauche sur davantage d'appareils, n'ont pas été terminées.

**Comptes et sécurité**

- La suppression d'un compte conserve les messages du chat pour l'autre personne.
- Le numéro de téléphone du propriétaire (`listings/{id}/contact/info`) est lisible avec la règle `signedIn()` : un compte Firebase anonyme compte comme connecté et peut donc le lire. La règle `notAnonymous()` (PR #44, fermée, jamais fusionnée) n'est pas dans `develop`.
- Le signalement et le blocage d'utilisateurs ne sont pas faits. La politique de confidentialité et la page de suppression de compte existent (`docs/privacy-policy.html`, `docs/delete-account.html`). Le bouton « Supprimer mon compte » est dans Paramètres (Flutter) ; il n'existe pas dans React Native. La page de suppression sert aux demandes faites hors application.
- La clé API Android n'a volontairement aucune restriction d'application (« Aucune »), décision de Manar du 21 novembre (VST-138 clos sans restriction). Raison : une restriction par nom de package et SHA-1 bloque la connexion dès qu'une clé de signature manque (debug, upload ou Google Play), avec une erreur générique, et un seul oubli casserait la connexion pour tous, y compris pour le jury. Une clé API Firebase n'est pas un secret ; la protection des données repose sur l'authentification et sur les règles Firestore (testées avec l'émulateur). Risque connu : une clé sans restriction peut être utilisée par une autre application et consommer le quota gratuit. La restriction par package et SHA-1 (décrite dans `firebase/README.md`) reste un travail futur.
- L'application n'a pas de Cloud Functions (offre gratuite) : la suppression de compte et le nettoyage s'exécutent depuis l'application.

**Application React Native**

- C'est un MVP réduit de l'application Flutter : connexion, recherche et filtres, liste et détails des annonces avec galerie de photos, formulaire de publication (équipements, règles, horaires), carte, alertes de messages et badge de messages non lus. Le chat React Native (VST-45, PR #102) est fusionné mais n'a pas été testé sur deux téléphones (avec l'application Flutter). Les boutons de contact Appeler et WhatsApp (VST-80, PR #103) sont fusionnés et testés par Eya sur un Redmi (Expo Go) ; leur bouton « Se connecter » ne fait rien, car l'écran de détails n'est accessible que connecté. Les onglets Favoris et Profil sont encore des écrans vides, et la navigation en invité, Mes annonces, la suppression du compte, l'onboarding et les paramètres ne sont pas faits. Pas d'assistant IA, de réservations ni d'avis.

**Contenu**

- Les 15 annonces de démonstration (titre « Démo – … », sans badge de vérification) utilisent des informations et des photos réelles. Les propriétaires, qui ont demandé à ne pas être nommés, ont donné un accord oral par téléphone pour un usage académique ; Eya l'a recueilli et il est noté dans `docs/content/sources.md`. Nous n'avons aucun accord écrit. Un lancement réel demanderait l'accord écrit de chaque propriétaire.

## Travaux futurs

- **Connexion avec Google et Apple.** Apple demande un compte développeur payant.
- **Séparer les annonces dans Firestore** en collections distinctes par type (ventes, locations, séjours), comme notre professeur l'a suggéré, avec des index par collection.
- **Recherche côté serveur** avec filtres et pagination, au lieu de lire les 100 plus récentes.
- **Firebase Storage** pour les photos, quand la facturation sera possible, à la place du base64.
- **Vraies notifications push** (Firebase Cloud Messaging) à la place des alertes dans l'application et locales.
- **Détection hors ligne** avant la publication, avec un message clair.
- **Demandes de réservation, avis et assistant IA**, dans les deux applications.
- **Réservation Flutter** (VST-92) : une branche `feature/VST-92-flutter-booking`, non fusionnée, contient le calcul des nuits et du prix (avec tests), 17 textes en arabe, français et anglais, et l'écran de demande (sans Firestore). Il manque la structure de données (`bookings`, `blockedNights`), les règles Firestore avec leurs tests et leur déploiement.
- **Signaler et bloquer des utilisateurs**, page de confidentialité et case des conditions à l'inscription.
- **Prise en charge du web pour les photos** (ajouter le script `pica` et lire des octets au lieu d'un chemin de fichier).
- **Relecture native de l'arabe** de tous les textes, alignée sur le glossaire tunisien.
- **Mode sombre** dans les Paramètres. Chaque écran utilise les jetons de couleur de la marque : il faut un second jeu de jetons et une vérification de chaque écran.
- **Changer le type d'offre d'une annonce existante** (vente, location ou séjour). Les statuts autorisés dépendent du type d'offre : un changement demande aussi une réinitialisation du statut et une modification des règles.
- **Statut des annonces, partie 2** (VST-136) : rubans de couleur pour réservé, loué et vendu sur la page de détails, statut « masqué » visible seulement par le propriétaire (règle Firestore et tests de l'émulateur), et nombre de favoris sur chaque carte de « Mes annonces ». La partie 1 est fusionnée et testée sur téléphone.
- **Protéger le numéro de contact des comptes anonymes** : règle `notAnonymous()` dans une PR séparée, avec tests des règles ; les règles sont déployées par Manar.
- **E-mail du profil** (VST-128) : le nom, la photo, le téléphone et l'e-mail sont modifiables. Mais l'e-mail dans `users/{uid}/private/contact` garde l'ancienne valeur après la confirmation du changement, jusqu'à la prochaine sauvegarde du profil avec le téléphone ; il faut le synchroniser dès le changement.
- **Plus de tests sur téléphones réels**, avec différents appareils et versions d'Android.
