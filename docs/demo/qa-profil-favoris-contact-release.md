# Fiche Q&R : module profil, favoris, contact et release (VST-121)

Présentation de 5 minutes sans notes, puis 2 questions de l'équipe. Chaque réponse ci-dessous vient du code, du rapport « limites et travaux futurs » ou du script de démo. Si une question sort de cette fiche, la bonne réponse est : « je ne sais pas, je vérifie avec Manar ».

## Résumé en 4 blocs (1 minute chacun)

**1. Contact.** L'annonce a deux boutons, Appeler et WhatsApp. WhatsApp apparaît seulement si le propriétaire l'a activé. Le numéro est normalisé par `phone_utils.dart` (+216 suivi de 8 chiffres). Il n'est pas dans le document public de l'annonce : il est dans `listings/{id}/contact/info`, lisible seulement par un utilisateur connecté.

**2. Favoris.** Un document par favori, `favorites/{uid}_{listingId}`. La liste est en direct, avec les filtres Tous, Acheter, Louer, Séjourner. Toucher un favori ouvre le détail de l'annonce. Si l'annonce a été supprimée, la ligne « annonce non disponible » propose Retirer.

**3. Profil.** Le profil public est dans `users/{uid}` : nom et photo. Le nom est obligatoire. La photo est compressée (environ 200 px, moins de 100 Ko) et stockée en base64. Le profil montre aussi « Mes annonces » en direct, avec suppression et changement de statut.

**4. Release.** L'application est en test fermé (Alpha), version 1.0.0. L'accès à la production est approuvé, mais la production est « Inactif » : rien n'est publié. La publication demande une release signée avec la clé d'upload, que Manar détient, puis l'examen de Google.

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
Test fermé Alpha, accès à la production approuvé, production « Inactif ». Google annonce de quelques heures à sept jours d'examen, parfois plus ; il ne donne pas de date. Manar décide de publier et fait la release avec la clé d'upload.

**Pourquoi publier du contenu de démonstration est un sujet ?**
Nous n'avons l'accord écrit d'aucun propriétaire. L'application ne contient que des annonces de démonstration, avec le numéro de l'équipe. Sur le Play Store public, tout le monde les verrait : c'est une décision de Manar.

## Limites à dire nous-mêmes

- Compte anonyme : peut lire le numéro (règle `notAnonymous()` pas dans `develop`).
- Photos en base64 dans Firestore, pas dans Storage.
- Pas d'alerte quand l'application est fermée (pas de push serveur).
- Modifier l'e-mail et le téléphone dans le profil (VST-128) est un travail futur. Le nom et la photo sont faits.
- Pas de test sur un téléphone réel de mon côté pour le contact : Appeler et WhatsApp s'ouvrent seulement sur un téléphone, et j'ai testé sur Chrome.

## À confirmer avec Manar avant la démo

- La version actuellement publiée en test fermé (1.0.0 ou 1.0.0+2) : mon doc de passation dit que 1.0.0+2 attend la clé d'upload.
- Le texte du store (#107) et la décision de publier.
