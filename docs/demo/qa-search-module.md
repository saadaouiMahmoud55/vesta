# Fiche de révision Q&R : le module recherche et filtres (VST-122)

Module : recherche et filtres Flutter, écrit par Eya (VST-40). Fichiers dans `flutter-app/lib/features/search/` : `search_filters.dart` (la logique des filtres), `search_filters_notifier.dart` (l'état et la lecture), `search_filters_sheet.dart` (le panneau de filtres), `search_screen.dart` (l'écran). Lit les annonces avec `ListingRepository.getLatestListings` dans `flutter-app/lib/features/listings/listing_repository.dart`. Tests : les tests de recherche dans `flutter-app/test/`.

## L'explication en 30 secondes

L'onglet Recherche lit une fois les 100 annonces les plus récentes, puis les filtre dans l'application. Les filtres sont un texte (ville ou titre), une fourchette de prix, un type d'offre (vente, location, séjour) et un type de bien. Le texte attend 400 ms après la dernière touche avant de filtrer. Les annonces vendues, louées, indisponibles et masquées ne sont pas proposées. Le filtrage est de la logique Dart pure, sans Firebase, donc facile à tester.

## Comment c'est construit

- **`SearchFilters`** (`search_filters.dart`) : données et logique simples. `matches(listing)` vérifie chaque filtre, `apply(listings)` garde l'ordre (plus récent d'abord) et retire les annonces indisponibles, `activeCount` donne le nombre du badge sur le bouton de filtres.
- **`SearchFiltersNotifier`** (`search_filters_notifier.dart`) : notifier Riverpod qui garde les filtres. `setCity` utilise un minuteur de 400 ms pour que seule la dernière frappe compte. Quand l'utilisateur connecté change, les filtres repartent vides.
- **`searchableListingsProvider`** : lit une fois les 100 annonces les plus récentes ; `searchResultsProvider` applique les filtres sur cette liste et transmet les états de chargement et d'erreur à l'écran.
- **Écran et panneau** : ils affichent seulement l'état et appellent le notifier.

## Questions probables et réponses courtes

1. **Pourquoi filtrer dans l'application et pas dans Firestore ?**
   Firestore demande un index composite pour chaque combinaison de filtres, et une fourchette de prix impose le premier tri sur `price`, donc « plus récent d'abord » serait perdu. Lire les 100 plus récentes (aucun index nécessaire) et les filtrer en mémoire est simple et rapide à notre échelle. Le commentaire du code le dit : si l'application grandit jusqu'à des milliers d'annonces, il faudra déplacer les filtres principaux dans la requête.

2. **Quelle est la limite de ce choix ?**
   Seules les 100 annonces les plus récentes sont recherchables. Une annonce plus ancienne n'apparaît pas dans la recherche, bien qu'elle soit toujours dans l'application. C'est dans le rapport comme limite connue et comme travail futur (recherche côté serveur avec pagination).

3. **Pourquoi attendre 400 ms après la saisie ?**
   Pour éviter de filtrer à chaque touche et garder l'écran fluide. Seule la dernière frappe compte (`Timer` dans `setCity`, annulé à chaque nouvelle touche et à la fermeture).

4. **Comment la recherche de ville gère-t-elle les accents et l'arabe ?**
   `normalizeSearchText` met en minuscules, retire les accents (donc « gabes » trouve « Gabès ») et supprime les espaces en trop. L'arabe est gardé tel quel, car il n'a ni casse ni accents. Le texte est comparé à la ville et au titre de l'annonce.

5. **Quelle est la différence entre « location » et « séjour » ?**
   Le filtre utilise `offerTypeOf(listing)`, jamais `listingType` seul : une location à la nuit est un séjour, une location au mois ou à l'année est une location, et une vente est une vente. C'est la même règle que les badges et les choix de statut (`docs/offer-types.md`).

6. **Pourquoi les annonces vendues ou masquées n'apparaissent-elles pas ?**
   `apply` retire toute annonce indisponible. Elles restent visibles dans les favoris (avec une bannière), mais la recherche ne doit pas proposer ce que personne ne peut louer ou acheter. Les annonces réservées restent visibles : la PR #106 documente ce choix.

7. **Que se passe-t-il quand l'utilisateur se déconnecte ou se connecte ?**
   Le provider surveille l'identifiant de l'utilisateur : la liste est relue et les filtres sont réinitialisés, donc un nouvel utilisateur ne voit jamais les filtres du précédent.

8. **Comment sont affichés le chargement et les erreurs ?**
   Le provider de résultats transmet l'état de chargement et d'erreur de la lecture à l'écran, avec un bouton pour réessayer. Une lecture qui échoue n'affiche pas un écran vide.

9. **Comment est-ce testé ?**
   `SearchFilters` n'a pas de Firebase, donc des tests unitaires couvrent chaque filtre, les accents, l'état vide et l'ordre.

10. **Qu'amélioreriez-vous avec plus de temps ?**
    Des filtres côté serveur et la pagination, des options de tri (prix, distance) et l'enregistrement d'une recherche.

## Limites honnêtes (à dire avant qu'on les demande)

- Seules les 100 annonces les plus récentes sont recherchées.
- Pas de choix de tri : plus récent d'abord uniquement.
- Pas de recherche par distance depuis l'utilisateur.
- La recherche React Native (VST-41, PR #105) est une version séparée pour l'application RN réduite.

## Si vous ne connaissez pas la réponse

Dire : « Cette partie est dans `search_filters.dart`, je peux vous montrer les lignes exactes. » Puis ouvrir le fichier. Ne pas deviner.
