# Handover : Mahmoud

## Tickets réalisés

- VST-79 : boutons Appeler / WhatsApp sur la fiche annonce, champ téléphone / WhatsApp dans le formulaire Publier (PR #66)
- VST-46 : Favoris (ajout, retrait, liste, filtres Tous / Acheter / Louer / Séjourner), PR #40
- VST-48 : Profil (modification du nom et de la photo, mes annonces), PR #46
- VST-128 : modification du téléphone et de l'e-mail dans le profil (PR #126, fusionnée)
- Tests des règles Firestore de l'application
- Build Android signé pour Google Play (1.0.0 en test interne, 1.0.0+2 en test fermé)

## Écrans

- Fiche annonce : boutons Appeler et WhatsApp
- Formulaire Publier : champ téléphone / WhatsApp avec validation
- Profil : informations de l'utilisateur connecté, modification du nom, de la photo, du téléphone et de l'e-mail, mes annonces
- Favoris : liste des annonces enregistrées, avec filtres

## Fichiers et dossiers principaux

- `phone_utils.dart` : normalisation et validation des numéros tunisiens (`formatPhone`)
- Widget `ContactButtons` : boutons Appeler et WhatsApp (via `url_launcher`)
- Repository des annonces : enregistrement du téléphone à la publication
- `AndroidManifest.xml` : déclarations `queries` pour lancer l'appel et WhatsApp
- `l10n/` : fichiers de traduction en / fr / ar (contact inclus)
- `tools/check-colors.js` : vérification des couleurs du design

## Données utilisées

- Profil : données de l'utilisateur connecté, lues depuis Firestore via un provider
- Favoris : un document par favori, `favorites/{uid}_{listingId}`
- `listings/{id}/contact/info` : numéro de téléphone, séparé du document de l'annonce. Il est lisible seulement par un utilisateur **connecté** (règle `signedIn()`).
- Règles Firestore : testées avec des tests automatisés (accès autorisé / refusé selon l'utilisateur)
- Release Google Play : build Android signé, puis publication via la Play Console. Aucune clé, mot de passe ni emplacement du keystore n'est écrit dans ce document ni dans le dépôt.

## État de la release Google Play (mis à jour le 18 nov. 2026)

- **Test interne** : actif, version 1.0.0 (code de version 1), sortie le 22 oct.
- **Test fermé** (canal Alpha) : actif, version 1.0.0+2 (code de version 2), déjà envoyée le 3 nov.
- **Production** : inactive, aucune release, aucun pays ajouté. L'accès à la production est approuvé, mais rien n'est publié.
- Pour la production, il faudra la version 1.0.0+3 (Manar prépare le changement du `pubspec.yaml`), signée avec la clé d'upload, puis l'examen de Google.

## Comment tester

1. Ouvrir une annonce : les boutons Appeler et WhatsApp s'affichent.
2. Appuyer sur Appeler puis WhatsApp : le numéro normalisé s'ouvre dans l'application du téléphone.
3. Publier une annonce avec un numéro valide, puis avec un numéro invalide : le formulaire refuse l'invalide.
4. Ouvrir Profil et Favoris, ajouter puis retirer un favori.
5. Lancer `flutter analyze`, `flutter test` (tous les tests passent) et `node tools/check-colors.js`.
6. Tester sur un téléphone Android réel : appel, WhatsApp, langue arabe (écran inversé, numéros restant de gauche à droite).

## Limites connues

- **Règle `notAnonymous` pas encore déployée** : dans `firestore.rules` de `develop`, `contact/info` utilise `signedIn()`. Un visiteur non connecté est bloqué (test automatisé), mais un compte Firebase **anonyme** compte comme connecté et peut lire le numéro. La règle `notAnonymous()` a été écrite et testée sur une ancienne branche (PR #44), jamais mergée. Elle reste à reporter dans `develop` (les règles sont déployées par Manar).
- **Preuve que le numéro est protégé** : la règle est `allow read: if signedIn();` sur `listings/{id}/contact/info` (`firestore.rules`, ligne 160). Le test `assertFails(getDoc(contactRef(anon())))` dans `rules.test.js` (ligne 568) prouve qu'un visiteur sans compte ne peut pas le lire. L'application ne connecte jamais personne en anonyme, donc le risque ne vient que d'un appel direct à Firebase par un compte anonyme créé hors de l'application.
- **E-mail dans `private/contact`** : après un changement d'e-mail (VST-128), l'e-mail stocké dans `private/contact` garde l'ancienne valeur.
- Pas de téléphone Android réel utilisé pour mes tests : validés sur Chrome, et sur la tablette de Manar.
- Clé d'upload Google Play détenue par Manar : je ne peux pas signer un nouveau build seul.

## Questions de VST-113

1. **Pourquoi le numéro est-il dans `listings/{id}/contact/info` et pas dans le document de l'annonce ?**
   Le document de l'annonce est public. `contact/info` a sa propre règle : lisible seulement par un utilisateur connecté (`signedIn()`). Un visiteur non connecté est bloqué (test automatisé).

2. **Un compte anonyme peut-il lire le numéro ?**
   Techniquement oui, car `signedIn()` compte un compte Firebase anonyme comme connecté. Mais l'application ne crée jamais de compte anonyme : le risque existe seulement pour quelqu'un qui appelle Firebase directement, en dehors de l'application. La règle `notAnonymous()` a été écrite et testée dans la PR #44 (jamais mergée). Elle reste à reporter dans `develop`, dans une PR séparée. Les règles sont déployées par Manar.

3. **Comment le numéro est-il validé et utilisé ?**
   `phone_utils.dart` accepte `+216`, `00216`, `216` ou 8 chiffres (premier chiffre 2, 3, 4, 5, 7 ou 9) et renvoie `+216XXXXXXXX`, ou `null` si invalide. Appeler ouvre `tel:`, WhatsApp ouvre `wa.me` avec un message selon le type d'offre. Les `queries` d'`AndroidManifest.xml` autorisent ces lancements.