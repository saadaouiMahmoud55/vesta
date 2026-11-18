# Vesta : user stories (MVP)

Personas : **Acheteur / locataire** (cherche et contacte) et **Propriétaire / agent** (publie et répond).
Format : « En tant que ..., je veux ..., afin de ... ». Les besoins fonctionnels du rapport viennent de cette liste.

## Authentification
- En tant que visiteur, je veux m'inscrire avec mon e-mail et un mot de passe, afin de pouvoir publier et enregistrer des annonces.
- En tant qu'utilisateur inscrit, je veux me connecter et rester connecté, afin de ne pas ressaisir mes informations à chaque fois.
- En tant qu'utilisateur inscrit, je veux me déconnecter, afin de terminer ma session en toute sécurité.

## Recherche et filtres
- En tant qu'acheteur, je veux filtrer les annonces par prix, lieu et type, afin de ne voir que les biens pertinents.
- En tant que locataire, je veux passer des annonces de vente aux annonces de location, afin de ne voir que ce qui répond à mon besoin.

## Détails d'une annonce
- En tant qu'acheteur, je veux parcourir les photos d'une annonce, afin de juger le bien.
- En tant que locataire, je veux voir le prix et la description, afin de comparer les biens.

## Publication
- En tant que propriétaire, je veux publier une annonce de vente ou de location avec des photos, afin que les acheteurs et les locataires la trouvent.
- En tant qu'agent, je veux définir le prix, le type et le lieu, afin que mon annonce apparaisse dans les bonnes recherches.
- En tant que propriétaire, je veux modifier ma propre annonce, afin de garder ses informations à jour.
- En tant que propriétaire, je veux supprimer ma propre annonce, afin de retirer un bien que je ne veux plus publier.

## Carte et géolocalisation
- En tant qu'acheteur, je veux voir les annonces sur une carte, afin de savoir où elles se trouvent.
- En tant que locataire, je veux voir les annonces près de ma position, afin de trouver des logements dans ma zone.

## Chat
- En tant qu'acheteur, je veux écrire au propriétaire, afin de poser mes questions sur le bien.
- En tant que propriétaire, je veux voir toutes mes conversations au même endroit, afin de répondre rapidement.

## Favoris
- En tant qu'acheteur, je veux enregistrer des annonces en favoris, afin de les retrouver plus tard.
- En tant que locataire, je veux retirer une annonce des favoris, afin que ma liste reste propre.

## Profil
- En tant qu'utilisateur, je veux modifier mon nom et ma photo, afin que les autres me reconnaissent.
- En tant que propriétaire, je veux voir mes propres annonces publiées, afin de les suivre.

## Alertes de messages (notifications dans l'application)
- En tant qu'utilisateur, je veux recevoir une notification quand je reçois un nouveau message, afin de ne pas manquer un acheteur ou un propriétaire.

## Types d'offre : vente, location, séjour (VST-100, voir `docs/offer-types.md`)
- En tant qu'acheteur, je veux un onglet « Acheter » avec les prix en TND, afin de ne comparer que les biens à vendre.
- En tant que locataire, je veux un onglet « Louer » avec le loyer mensuel, la caution et l'information meublé, afin de connaître mon coût réel.
- En tant que voyageur, je veux un onglet « Séjourner » avec le prix par nuit, les voyageurs, les équipements et les règles de la maison, afin de choisir une maison d'hôtes ou un logement type Airbnb.
- En tant que vendeur, je veux choisir « Vendre » à la publication et ne voir que les champs utiles pour une vente, afin que publier soit rapide.
- En tant que bailleur, je veux choisir « Louer » et ajouter la caution, la date de disponibilité et le caractère meublé, afin que les locataires connaissent les conditions avant d'appeler.
- En tant qu'hôte, je veux choisir « Proposer un séjour » et ajouter les équipements, l'heure d'arrivée et les règles de la maison, afin que les voyageurs sachent à quoi s'attendre.
- En tant qu'utilisateur, je veux appeler ou écrire sur WhatsApp au propriétaire en un geste, afin de le joindre à la manière tunisienne.
- En tant que propriétaire, je veux marquer une annonce comme vendue, louée ou indisponible, afin que personne ne me contacte pour un bien parti.
- En tant qu'utilisateur, je veux que les repères de la carte montrent le type d'offre par la couleur, afin de comprendre la carte d'un coup d'œil.
- En tant qu'invité (sans compte), je veux parcourir les annonces et leurs détails, afin de décider de m'inscrire plus tard.
- En tant qu'utilisateur, je veux signaler une annonce suspecte ou bloquer un utilisateur, afin d'être protégé des arnaques. *(Non réalisé : voir les travaux futurs du rapport.)*
- En tant qu'utilisateur, je veux supprimer mon compte et mes données depuis l'application, afin de contrôler mes informations.
