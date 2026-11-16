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
- En mode modification, le propriétaire ne peut pas changer le type d'offre (vente ou location) ni la période de location, car les statuts autorisés en dépendent.

**Langue**

- Les noms saisis par les utilisateurs (nom du profil) restent dans les lettres saisies. L'application ne translittère pas entre l'alphabet latin et l'arabe.
- Une relecture des textes arabes et français par des locuteurs natifs, et une vérification de l'affichage de droite à gauche sur davantage d'appareils, n'ont pas été terminées.

**Comptes et sécurité**

- La suppression d'un compte conserve les messages du chat pour l'autre personne.
- Le signalement et le blocage d'utilisateurs, ainsi que la page de confidentialité, n'ont pas été terminés (voir le handover d'Eya).
- La clé API Android est limitée à nos applications par nom de package et SHA-1. Chaque nouveau développeur ou nouvelle clé de signature doit avoir sa propre ligne, et un changement prend environ 5 minutes.
- L'application n'a pas de Cloud Functions (offre gratuite) : la suppression de compte et le nettoyage s'exécutent depuis l'application.

**Application React Native**

- C'est un MVP réduit de l'application Flutter : connexion, navigation, recherche et une partie des annonces (la carte, PR #91, seulement si elle est fusionnée avant le gel du code). Les alertes de messages et le badge de messages non lus de l'application React Native (PR #111) sont présents. Le chat React Native (VST-45, PR #102) et les boutons de contact (VST-80, PR #103) sont dans des PR ouvertes, non fusionnées avant le gel et non testées sur téléphones réels. Pas d'assistant IA, de réservations ni d'avis. Les annonces (VST-39) n'ont pas été terminées.

**Contenu**

- Nous n'avons l'accord écrit d'aucun propriétaire, donc il n'y a aucune vraie annonce, même sur Google Play. L'application contient uniquement du contenu de démonstration (annonces « Démo – … », avec le numéro de l'équipe et sans badge de vérification). Un lancement réel demanderait l'accord écrit de chaque propriétaire.

## Travaux futurs

- **Connexion avec Google et Apple.** Apple demande un compte développeur payant.
- **Séparer les annonces dans Firestore** en collections distinctes par type (ventes, locations, séjours), comme notre professeur l'a suggéré, avec des index par collection.
- **Recherche côté serveur** avec filtres et pagination, au lieu de lire les 100 plus récentes.
- **Firebase Storage** pour les photos, quand la facturation sera possible, à la place du base64.
- **Vraies notifications push** (Firebase Cloud Messaging) à la place des alertes dans l'application et locales.
- **Détection hors ligne** avant la publication, avec un message clair.
- **Demandes de réservation, avis et assistant IA**, dans les deux applications.
- **Signaler et bloquer des utilisateurs**, page de confidentialité et case des conditions à l'inscription.
- **Prise en charge du web pour les photos** (ajouter le script `pica` et lire des octets au lieu d'un chemin de fichier).
- **Relecture native de l'arabe** de tous les textes, alignée sur le glossaire tunisien.
- **Mode sombre** dans les Paramètres. Chaque écran utilise les jetons de couleur de la marque : il faut un second jeu de jetons et une vérification de chaque écran.
- **Changer le type d'offre d'une annonce existante** (vente, location ou séjour). Les statuts autorisés dépendent du type d'offre : un changement demande aussi une réinitialisation du statut et une modification des règles.
- **Statut des annonces, partie 2** (VST-136) : rubans de couleur pour réservé, loué et vendu sur la page de détails, statut « masqué » visible seulement par le propriétaire (règle Firestore et tests de l'émulateur), et nombre de favoris sur chaque carte de « Mes annonces ». La partie 1 est fusionnée et testée sur téléphone.
- **Modifier l'e-mail et le téléphone dans le profil** (VST-128) : le nom et la photo sont déjà faits.
- **Plus de tests sur téléphones réels**, avec différents appareils et versions d'Android.
