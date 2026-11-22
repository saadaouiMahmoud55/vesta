# Vesta : plan des diapositives de la soutenance (VST-68)

Plan texte des 13 diapositives, avec les notes de l'orateur. Les diapositives elles-mêmes sont dans l'artefact « Vesta : soutenance finale » ; ce fichier garde le contenu dans le dépôt, pour le modifier ou l'exporter. Durée visée : 10 minutes. État de `develop` au 19 novembre (#103 fusionnée, production Google Play publiée).

## 1. Couverture

**Vesta** : acheter, louer, vendre et séjourner en Tunisie, en arabe, français et anglais.
Mini-projet, ISET Tozeur, novembre 2026. Manar Degachi, Eya Ben Belgacem, Ahmed Bouguerra, Mahmoud Saadaoui.

*Notes :* dire d'abord ce qu'est Vesta, puis comment c'est construit, puis ce qui marche et ce qui manque. Rester honnête sur React Native et sur les limites.

## 2. Une seule application pour trois façons d'habiter

- **Vente** : acheter ou vendre. Maisons, villas, appartements, terrains, locaux. Prix en TND, sans unité.
- **Location** : prix par mois ou par an, caution, date de disponibilité, meublé ou non.
- **Séjour** : riads, maisons d'hôtes, prix par nuit, voyageurs, équipements, règles de la maison.

Les trois offres viennent de deux champs existants, `listingType` et `rentPeriod`.

*Notes :* chaque offre a ses champs et la couleur de son badge. Une seule fonction, `offerTypeOf`, décide de l'offre dans les deux applications.

## 3. Deux applications, un seul back-end

- **Flutter** : l'application complète, sur Google Play (test interne et fermé, puis production publiée le 19 novembre).
- **React Native** : la version réduite, en démonstration académique.
- **Firebase** : Authentication et Firestore (offre gratuite), plus OpenStreetMap pour la carte.

*Notes :* Flutter est l'application complète, React Native est volontairement réduite. Les deux se connectent au même projet Firebase.

## 4. Un écran ne parle jamais à Firebase

Écran → Contrôleur → Dépôt → Firebase. Même découpage dans les neuf modules : Auth, Recherche, Détails, Publier, Carte, Chat, Favoris, Profil, Notifications. Modèle C4 dans `docs/c4`.

*Notes :* cette règle rend les contrôleurs testables sans Firebase. Le modèle de données et les règles sont dans `docs/data-model.md` et `firebase/firestore.rules`.

## 5. L'offre gratuite a décidé de nos contournements

| Besoin | Notre choix | Pourquoi |
| --- | --- | --- |
| Photos | base64 dans Firestore, 10 au maximum | Storage demande l'offre payante |
| Carte | OpenStreetMap | aucune clé ni facturation |
| Notifications | alertes dans l'application, compteur de non lus | le push demande des Cloud Functions |
| Numéro de téléphone | document privé, comptes connectés seulement | les annonces sont publiques aux invités |

*Notes :* les règles Firestore ne savent pas compter des documents : les photos ont des identifiants fixes `p0` à `p9`.

## 6. Flutter couvre tout le MVP

Inscription et connexion, navigation en invité, recherche et filtres, détails et photos, publier, modifier, supprimer, carte et « ma position », chat, Appeler et WhatsApp, favoris, profil et photo, alertes et messages non lus, statut de l'annonce, suppression du compte, onboarding et paramètres.

Coupé avant le gel du code : réservations, avis, assistant IA, tableau de bord du propriétaire.

*Notes :* montrer la démonstration en direct ici, dans l'ordre du script `docs/demo/demo-script.md`.

## 7. Un thème, trois langues, deux sens de lecture

- Une seule palette : les couleurs du thème Figma, avec un contrôle automatique.
- Une seule source de textes : un fichier maître génère les textes Flutter et React Native en arabe tunisien (droite à gauche), français et anglais ; la CI vérifie qu'aucune langue ne manque.
- Les prix et les numéros restent de gauche à droite, même en arabe.

*Notes :* changer la langue en direct dans les Paramètres. Les couleurs viennent de `AppColors` et de `theme.ts`.

## 8. React Native : une version réduite, dont l'état est clair

- **Fait :** inscription et connexion, recherche et filtres, liste et détails avec galerie de photos, formulaire de publication avec équipements, carte et géolocalisation, alertes et messages non lus.
- **Fait aussi :** chat (#102) et boutons Appeler / WhatsApp dans le détail (#103), fusionnés ; résultats des tests sur téléphone dans VST-59.
- **Pas fait :** favoris et profil (onglets vides), navigation en invité, modifier et supprimer une annonce, suppression du compte, onboarding et paramètres.

*Notes :* état de `develop` au 19 novembre. Le chat s'ouvre par le bouton « Messages » de l'accueil.

## 9. Chaque changement est contrôlé avant de rejoindre develop

- 174 tests Flutter réussis, analyse sans alerte.
- 116 tests React Native réussis sur develop.
- 60 cas de test manuels sur téléphone réel.
- Règles Firestore testées avec l'émulateur ; contrôle des couleurs et des traductions à chaque pull request ; relecture avant la fusion.

Les tests sur téléphone ont trouvé un prix absurde accepté par les règles, des filtres qui se réinitialisaient et un œil de mot de passe faux.

## 10. Sur Google Play, avec du contenu de démonstration

- **Test interne et test fermé :** version 1.0.0 disponible depuis le 22 octobre (build 1), build 2 en test fermé. **Production :** build 3 (1.0.0+3) publié le 19 novembre 2026, disponible sur Google Play. Plan B pour la démo : lien du test fermé et application sur deux téléphones. Fiche en trois langues.
- **15 annonces « Démo » réelles :** informations et photos réelles, avec l'accord oral des propriétaires (usage académique, notés dans `docs/content/sources.md`). Aucun accord écrit, pas de badge vérifié.

*Notes :* dire clairement que l'accord est oral et que les propriétaires ont demandé à ne pas être nommés. Un lancement réel demanderait un accord écrit.

## 11. Ce qui manque, et ce que nous ferions ensuite

- **Limites :** photos en base64, recherche sur les 100 annonces les plus récentes (la recherche par ville ne relie pas l'arabe et le latin), numéro de contact lisible par un compte anonyme, description sans minimum de 40 caractères (VST-137), relecture native de l'arabe à finir.
- **Travaux futurs :** notifications push et Storage, règle de sécurité pour le contact, recherche côté serveur, réservations, avis, assistant IA, mode sombre.

*Notes :* la plupart des limites viennent d'un seul choix, rester sur l'offre gratuite de Firebase. Détail dans `docs/report/limits-and-future-work.md`.

## 12. Quatre personnes, un dépôt, des relectures

- **Manar :** cheffe de groupe. Firebase, règles, thème, chat, carte, intégration.
- **Eya :** annonces, recherche et publication, contenu de démonstration, relectures.
- **Ahmed :** qualité, UI kit, traductions, authentification et navigation React Native.
- **Mahmoud :** favoris, profil, contact, tests des règles, build Google Play.

Jira par sprints, une branche et une pull request par tâche, une relecture avant chaque fusion, une fiche de questions-réponses sur le module d'un autre.

## 13. Conclusion

Une application qui marche de bout en bout, des limites connues et écrites. Flutter est complet et testé sur téléphone ; React Native est réduit, avec la même architecture. Rapport, plan de test et fiches de questions-réponses sont dans le dépôt. Merci. Questions ?
