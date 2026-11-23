# Script de démonstration Vesta (version finale, mar. 24 nov. à 08:30)

Rédigé à partir de ce qui est fusionné dans `develop` (modification d'annonce, suppression et agrandissement de la photo de profil, chat et boutons de contact React Native), mis à jour le 21 nov. : la version 1.0.0 (3) est publiée sur Google Play. Toutes les pull requests de fonctionnalités sont fusionnées ; si on change quelque chose, vérifier l'étape correspondante avant la démo. Les comptes de test et les personnes qui parlent sont des valeurs à compléter.

## Avant la démo (lundi soir ; l'installation et la vérification des téléphones peuvent se faire dès dimanche)

- Installer l'application **depuis Google Play** (version 1.0.0 (3)) sur le téléphone principal, avec un compte Google qui n'est pas celui du développeur, et vérifier que la connexion fonctionne. Sur le second téléphone, installer le même build depuis Google Play, ou l'APK debug construit depuis `develop` en secours. La clé API Android n'a volontairement aucune restriction d'application (décision du 21 nov.), donc tous les builds peuvent se connecter ; ne pas la restreindre avant la démo.
- **Application React Native (Expo Go) :** elle n'est pas sur Google Play ; elle tourne depuis l'ordinateur. Récupérer le tag `v1.0.0-rc1` (`git checkout v1.0.0-rc1`), vérifier que la configuration Firebase locale est en place, lancer `npm install` puis `npx expo start` (avec `--tunnel` si le réseau est instable), et ouvrir le projet dans Expo Go sur le téléphone de démonstration. Faire une fois le parcours complet (connexion, recherche, détails, carte, chat, boutons Appeler et WhatsApp). L'application n'a pas de numéro de version propre (`0.0.1` dans `app.json`) : la citer comme « React Native, tag v1.0.0-rc1 ».
- Plan B React Native : un enregistrement d'écran de 30 secondes du parcours, gardé sur le téléphone, si l'ordinateur ou le réseau ne marche pas le jour de la démo.
- Plan B si la fiche Google Play ne s'ouvre pas : le lien du test fermé, l'APK sur deux téléphones et une capture de la Console (Production, 100 %).
- Créer deux comptes de test : **Propriétaire** et **Client**. Le Propriétaire a 2 ou 3 annonces (une vente, une location, un séjour) avec de vraies photos et une position exacte.
- Mettre un téléphone en arabe et l'autre en français, pour que le passage de droite à gauche soit visible. **Le téléphone Client, celui qui fait les recherches des étapes 1 et 3, reste en français** : la recherche par ville ne marche qu'en lettres latines (limite connue). Il ne passe en arabe qu'à l'étape 7.
- Charger les téléphones, couper les notifications des autres applications, se connecter à un réseau stable. Garder un second réseau (partage de connexion) prêt.
- Avoir l'application déjà déconnectée sur le téléphone Client, pour montrer d'abord la navigation en invité.
- Fermer toutes les autres applications. Garder un enregistrement d'écran du parcours complet en secours.
- **Répétition :** faire deux passages complets chronométrés (cible 8 minutes, maximum 10), dont un en changeant de personne qui parle à chaque étape. Après chaque passage, noter ce qui a échoué et le corriger dans les données (pas dans le code).

## Déroulé (environ 8 minutes)

**1. Ouvrir et parcourir en invité (1 min).** Ouvrir l'application sans compte. L'écran Explorer affiche les annonces. Dire : *« On peut parcourir sans s'inscrire ; un compte n'est nécessaire que pour contacter, mettre en favori ou publier. »* Chercher une ville **en lettres latines** (par exemple « Tozeur », application en français) et filtrer par type d'offre. Ne pas chercher en lettres arabes : la recherche ne fait pas le lien entre l'écriture arabe et latine (limite connue).

**2. Détails d'une annonce (1 min).** Ouvrir une annonce. Montrer le prix et le badge d'offre (vente, location, séjour), les photos, les équipements, et la petite carte avec la position exacte et le bouton **Ouvrir dans Maps**. Appuyer sur **Contacter le propriétaire** : l'application demande à l'invité de se connecter. Se connecter avec le compte Client. Montrer ensuite les boutons **Appeler** et **WhatsApp** (WhatsApp seulement si le propriétaire l'a activé).

**3. Carte (1 min).** Ouvrir l'onglet Carte. Toutes les annonces apparaissent en repères avec le prix ; appuyer sur un repère pour voir l'aperçu, appuyer sur l'aperçu pour ouvrir les détails. Chercher une ville tunisienne, en lettres latines, application en français.

**4. Favoris et chat (1,5 min).** Mettre une annonce en favori, ouvrir Favoris, appuyer dessus : les détails s'ouvrent. Envoyer le premier message au propriétaire. Montrer le bandeau de l'annonce en haut du chat et le séparateur de date.

**5. Côté propriétaire : notifications et Mes annonces (1,5 min).** Sur le téléphone du Propriétaire : la cloche et l'icône du chat affichent un badge de messages non lus ; le centre de notifications liste la conversation et ouvre le bon chat. Dire clairement : *« Les alertes fonctionnent quand l'application est ouverte ; il n'y a pas de push serveur, car cela demande une offre payante. »* Puis Profil > Mes annonces : changer un statut (disponible, réservé, vendu).

**6. Publier et modifier (1,5 min).** Publier une annonce : champs, ville, choix de la position exacte, jusqu'à 10 photos (les doublons sont ignorés). Modifier l'annonce depuis Mes annonces : le formulaire est pré-rempli, changer le prix et une photo, enregistrer, puis montrer l'annonce mise à jour sur le téléphone Client.

**7. Profil, langue et sécurité (1 min).** Profil : modifier le nom et la photo, supprimer la photo, appuyer sur la photo pour la voir en grand. Paramètres : changer la langue entre arabe, français et anglais, et montrer que la mise en page passe de droite à gauche. Mentionner que le compte peut être supprimé depuis les Paramètres.

**8. Application React Native (30 s).** Dire franchement que l'application React Native est une version réduite (connexion, recherche et filtres, détails et publication, carte, chat, boutons Appeler et WhatsApp ; favoris et profil encore vides), et que Flutter est l'application complète. **Ne pas répondre à un message depuis le chat React Native** : sur le Redmi testé le 22 novembre, la zone de saisie est masquée par la barre de navigation Android (cas X-04). Montrer seulement la liste des messages et la lecture d'un message reçu, et dire que c'est une limite connue.

## Ce que nous disons sur les limites

Les dire nous-mêmes avant que le jury ne les demande. La liste complète est dans le rapport (« limites et travaux futurs ») :

- Les photos sont stockées en texte compressé dans Firestore (pas de Storage payant) ; maximum 10 par annonce.
- Pas d'alerte quand l'application est fermée (pas de push serveur, pas d'offre payante).
- La recherche lit les 100 annonces les plus récentes et filtre dans l'application.
- Chat React Native : la lecture marche, mais on ne peut pas répondre depuis le Redmi testé (zone de saisie masquée par la barre de navigation Android, cas X-04) ; limite connue, non corrigée après le gel.
- La recherche par ville compare le texte tel qu'il est stocké dans l'annonce : elle ne fait pas le lien entre les lettres arabes et latines (constaté pendant la répétition du 22 novembre).
- Les noms saisis par les utilisateurs ne sont ni traduits ni translittérés.
- La connexion Google et Apple est un travail futur ; les annonces ne sont pas encore séparées en collections par type.
- Les annonces réelles ne sont publiées qu'avec l'accord écrit du propriétaire ; les autres sont indiquées comme contenu de démonstration.

## Si quelque chose échoue pendant la démo

- **La connexion échoue sur un téléphone :** vérifier d'abord le réseau (passer sur le partage de connexion) et réessayer avec l'autre compte de test. Lancer l'enregistrement d'écran de l'étape de connexion et continuer.
- **Réseau lent ou absent :** passer sur le partage de connexion. Si c'est encore lent, lancer l'enregistrement d'écran de cette étape.
- **Une photo ou une annonce ne se charge pas :** passer à l'annonce suivante ; ne pas réessayer plus d'une fois sur scène.
- **L'application plante :** la rouvrir, se reconnecter et continuer à l'étape suivante.

## Questions probables (préparer une réponse chacune)

1. **Pourquoi Firebase et pas notre propre backend ?** Offre gratuite, développement rapide, et les règles de sécurité protègent les données (modification réservée au propriétaire, contact privé, annonces valides uniquement).
2. **Comment protégez-vous le numéro de téléphone du propriétaire ?** Il est dans un document privé séparé, lisible seulement par les utilisateurs connectés ; les invités ne peuvent pas le lire. Limite connue : un compte Firebase anonyme compte comme connecté et pourrait le lire, car la règle `notAnonymous()` (PR #44, fermée) n'est pas dans `develop`. C'est dans les travaux futurs.
3. **Comment le mode modification garde-t-il les données valides ?** Un seul lot d'écritures met à jour l'annonce, ses photos et son contact ensemble ; le type d'offre et la période sont verrouillés pour que les règles de statut restent valides.
4. **Comment gérez-vous l'arabe ?** Les fichiers texte (CSV) génèrent les traductions Flutter et React Native ; les prix, numéros de téléphone et e-mails sont forcés de gauche à droite dans les écrans de droite à gauche.
5. **Que feriez-vous avec plus de temps ?** Voir « Travaux futurs » dans le rapport.
6. **Comment avez-vous travaillé en équipe ?** Des sprints dans Jira, une branche et une pull request par ticket, une revue obligatoire, et une vérification verte (traductions, couleurs, analyse, tests) avant chaque fusion.
7. **Pourquoi la clé API Android n'est-elle pas restreinte ?** Une restriction par package et SHA-1 bloque la connexion dès qu'une clé de signature manque (debug, upload, Google Play) ; nous l'avons vécu. Une clé Firebase n'est pas un secret : les données sont protégées par l'authentification et les règles Firestore, que nous testons avec l'émulateur. Risque connu : une autre application peut consommer le quota gratuit. La restriction est décrite dans `firebase/README.md` et reste un travail futur.
8. **L'application est-elle publiée ?** Oui, la version 1.0.0 (3) est en production sur Google Play (Tunisie) depuis le 19 novembre ; les annonces visibles sont des annonces de démonstration.
9. **La recherche marche-t-elle en arabe ?** Pas pour une ville écrite en lettres arabes : elle compare le texte tel qu'il est stocké dans l'annonce (ici en lettres latines, par exemple « Tozeur ») et ne fait pas le lien entre les deux écritures. C'est une limite connue, écrite dans le rapport, et un travail futur (recherche côté serveur et noms de villes dans les deux écritures). Ne pas la montrer sur scène.
