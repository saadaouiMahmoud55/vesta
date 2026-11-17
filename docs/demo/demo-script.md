# Script de démonstration Vesta (mar. 17 nov.)

Rédigé à partir de ce qui est fusionné dans `develop` le 16 nov. (modification d'annonce, suppression et agrandissement de la photo de profil, carte React Native). Si une pull request est fusionnée après cette date, vérifier l'étape correspondante avant la démo. Les comptes de test et les personnes qui parlent sont des valeurs à compléter.

## Avant la démo (dimanche soir)

- Construire l'APK debug depuis la version finale de `develop` et l'installer sur deux téléphones. Vérifier que la connexion fonctionne sur les deux. La clé API Android n'a actuellement aucune restriction d'application, donc n'importe quel APK peut se connecter. Installer quand même le même APK sur les deux téléphones. Si la restriction par nom de package et SHA-1 est remise avant la démo, le SHA-1 appartient au keystore qui a signé l'APK (le PC qui l'a construit), pas au téléphone : construire alors l'APK sur un PC dont le SHA-1 est déjà dans la clé.
- Créer deux comptes de test : **Propriétaire** et **Client**. Le Propriétaire a 2 ou 3 annonces (une vente, une location, un séjour) avec de vraies photos et une position exacte.
- Mettre un téléphone en arabe et l'autre en français, pour que le passage de droite à gauche soit visible.
- Charger les téléphones, couper les notifications des autres applications, se connecter à un réseau stable. Garder un second réseau (partage de connexion) prêt.
- Avoir l'application déjà déconnectée sur le téléphone Client, pour montrer d'abord la navigation en invité.
- Fermer toutes les autres applications. Garder un enregistrement d'écran du parcours complet en secours.

## Déroulé (environ 8 minutes)

**1. Ouvrir et parcourir en invité (1 min).** Ouvrir l'application sans compte. L'écran Explorer affiche les annonces. Dire : *« On peut parcourir sans s'inscrire ; un compte n'est nécessaire que pour contacter, mettre en favori ou publier. »* Chercher une ville (essayer une orthographe arabe) et filtrer par type d'offre.

**2. Détails d'une annonce (1 min).** Ouvrir une annonce. Montrer le prix et le badge d'offre (vente, location, séjour), les photos, les équipements, et la petite carte avec la position exacte et le bouton **Ouvrir dans Maps**. Appuyer sur **Contacter le propriétaire** : l'application demande à l'invité de se connecter. Se connecter avec le compte Client. Montrer ensuite les boutons **Appeler** et **WhatsApp** (WhatsApp seulement si le propriétaire l'a activé).

**3. Carte (1 min).** Ouvrir l'onglet Carte. Toutes les annonces apparaissent en repères avec le prix ; appuyer sur un repère pour voir l'aperçu, appuyer sur l'aperçu pour ouvrir les détails. Chercher une ville tunisienne.

**4. Favoris et chat (1,5 min).** Mettre une annonce en favori, ouvrir Favoris, appuyer dessus : les détails s'ouvrent. Envoyer le premier message au propriétaire. Montrer le bandeau de l'annonce en haut du chat et le séparateur de date.

**5. Côté propriétaire : notifications et Mes annonces (1,5 min).** Sur le téléphone du Propriétaire : la cloche et l'icône du chat affichent un badge de messages non lus ; le centre de notifications liste la conversation et ouvre le bon chat. Dire clairement : *« Les alertes fonctionnent quand l'application est ouverte ; il n'y a pas de push serveur, car cela demande une offre payante. »* Puis Profil > Mes annonces : changer un statut (disponible, réservé, vendu).

**6. Publier et modifier (1,5 min).** Publier une annonce : champs, ville, choix de la position exacte, jusqu'à 10 photos (les doublons sont ignorés). Modifier l'annonce depuis Mes annonces : le formulaire est pré-rempli, changer le prix et une photo, enregistrer, puis montrer l'annonce mise à jour sur le téléphone Client.

**7. Profil, langue et sécurité (1 min).** Profil : modifier le nom et la photo, supprimer la photo, appuyer sur la photo pour la voir en grand. Paramètres : changer la langue entre arabe, français et anglais, et montrer que la mise en page passe de droite à gauche. Mentionner que le compte peut être supprimé depuis les Paramètres.

**8. Application React Native (30 s).** Dire franchement que l'application React Native est une version réduite (connexion, navigation, une carte, une partie des annonces), et que Flutter est l'application complète.

## Ce que nous disons sur les limites

Les dire nous-mêmes avant que le jury ne les demande. La liste complète est dans le rapport (« limites et travaux futurs ») :

- Les photos sont stockées en texte compressé dans Firestore (pas de Storage payant) ; maximum 10 par annonce.
- Pas d'alerte quand l'application est fermée (pas de push serveur, pas d'offre payante).
- La recherche lit les 100 annonces les plus récentes et filtre dans l'application.
- Les noms saisis par les utilisateurs ne sont ni traduits ni translittérés.
- La connexion Google et Apple est un travail futur ; les annonces ne sont pas encore séparées en collections par type.
- Les annonces réelles ne sont publiées qu'avec l'accord écrit du propriétaire ; les autres sont indiquées comme contenu de démonstration.

## Si quelque chose échoue pendant la démo

- **La connexion échoue sur un téléphone :** vérifier d'abord le réseau (passer sur le partage de connexion) et réessayer avec l'autre compte de test. Si la restriction d'application de la clé API a été remise, le SHA-1 de cette version manque peut-être : lancer l'enregistrement d'écran de l'étape de connexion et continuer, puis lancer `gradlew signingReport` sur le PC qui a construit l'APK et ajouter le SHA-1 à la clé.
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
