# Fiche Q&R : module profil, favoris, contact et release (VST-121)

Présentation de 5 minutes sans notes, puis 2 questions de l'équipe. Chaque réponse ci-dessous vient du code, du rapport « limites et travaux futurs » ou du script de démo. Si une question sort de cette fiche, la bonne réponse est : « je ne sais pas, je vérifie avec Manar ».

## Résumé en 4 blocs (1 minute chacun)

**1. Contact.** L'annonce a deux boutons, Appeler et WhatsApp. WhatsApp apparaît seulement si le propriétaire l'a activé. Le numéro est normalisé par `phone_utils.dart` (+216 suivi de 8 chiffres). Il n'est pas dans le document public de l'annonce : il est dans `listings/{id}/contact/info`, lisible seulement par un utilisateur connecté.

**2. Favoris.** Un document par favori, `favorites/{uid}_{listingId}`. La liste est en direct, avec les filtres Tous, Acheter, Louer, Séjourner. Toucher un favori ouvre le détail de l'annonce. Si l'annonce a été supprimée, la ligne « annonce non disponible » propose Retirer.

**3. Profil.** Le profil public est dans `users/{uid}` : nom et photo. Le nom est obligatoire. La photo est compressée (environ 200 px, moins de 100 Ko) et stockée en base64. Le profil montre aussi « Mes annonces » en direct, avec suppression et changement de statut.

**4. Release.** L'application a été en test interne (build 1) puis en test fermé Alpha (build 2). Le build 3 (1.0.0+3, signé avec la clé d'upload par Manar) a été envoyé en production par Mahmoud et publié le 19 novembre 2026 (déploiement à 100 %, fiche Google Play disponible avec le bouton Installer).

## Questions probables

**Où est stocké le numéro de téléphone, et qui peut le lire ?**
Dans `listings/{id}/contact/info`, séparé du document de l'annonce. La règle `signedIn()` autorise les utilisateurs connectés. Un invité ne peut pas le lire.

**Et un compte anonyme ?**
Limite connue : un compte Firebase anonyme compte comme connecté, donc il peut lire le numéro. La règle `notAnonymous()` a été écrite et testée dans la PR #44 (fermée, jamais fusionnée). Elle n'est pas dans `develop`. C'est dans les travaux futurs du rapport : une PR séparée avec tests de règles, déployées par Manar.

**Pourquoi un seul document par favori avec l'identifiant `{uid}_{listingId}` ?**
Le même utilisateur et la même annonce donnent toujours le même document, donc il ne peut pas y avoir de doublon.

**Que se passe-t-il si une annonce favorite est supprimée par son propriétaire ?**
Pas de plantage. La ligne affiche « annonce non disponible » et un bouton Retirer pour nettoyer la liste.

**Pourquoi la photo est en base64 dans Firestore et pas dans Firebase Storage ?**
Le rapport l'explique : Firebase Storage n'est pas dans l'offre gratuite. Pour le profil, la photo est réduite (environ 200 px, moins de 100 Ko). Pour les annonces : 10 photos maximum, environ 800 px. Le passage à Storage est dans les travaux futurs.

**Comment le formulaire de profil évite-t-il un double envoi ?**
Le contrôleur ignore une nouvelle sauvegarde tant que la précédente est en cours (`isLoading`). Les erreurs sont des valeurs (réseau, permission, non connecté, inconnu) traduites par l'écran, pas du texte dans la logique.

**Le téléphone est-il obligatoire à la publication ?**
Oui. En modification, il reste obligatoire si l'annonce avait déjà un numéro. Il peut rester vide seulement si l'annonce n'en avait pas (correctif de la PR #97).

**Où en est la publication sur Google Play ?**
Le build 3 (1.0.0+3) est publié en production depuis le 19 novembre 2026, après le test interne et le test fermé Alpha. Manar fait la release avec la clé d'upload ; Mahmoud l'envoie depuis le compte développeur.

**Pourquoi publier du contenu de démonstration est un sujet ?**
Nos 15 annonces utilisent des informations et des photos réelles, avec l'accord oral des propriétaires (voir docs/content/sources.md), mais nous n'avons aucun accord écrit.

## Limites à dire nous-mêmes

VST-128 est fusionnée (#126). Limite restante : l'e-mail stocké dans private/contact garde l'ancienne valeur après un changement d'e-mail, jusqu'à la prochaine sauvegarde du profil avec le téléphone.

## À confirmer avec Manar avant la démo

- Versions Google Play : build 1 (1.0.0) en test interne, build 2 (1.0.0+2) en test fermé, build 3 (1.0.0+3) signé, envoyé en production et publié le 19 novembre 2026.
- Le texte du store (#107) et la décision de publier.
