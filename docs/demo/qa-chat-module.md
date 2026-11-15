# Fiche de révision Q&R : le module chat (VST-120)

Module : chat Flutter, écrit par Manar (VST-44, alerte VST-50, cloche VST-99). Fichiers dans `flutter-app/lib/features/chat/` : `chat_repository.dart`, `chat_controller.dart`, `chat_models.dart`, `chat_list_screen.dart`, `chat_screen.dart`. Règles dans `firebase/firestore.rules` (bloc `conversations`). Tests : `chat_models_test.dart`, `chat_screen_test.dart`.

## L'explication en 30 secondes

Un acheteur ouvre une annonce et appuie sur Chat. Il y a une conversation par annonce et par acheteur, avec l'identifiant `{listingId}_{buyerId}`. Les messages sont dans une sous-collection `messages`. Le document de conversation est créé avec le premier message : ouvrir un chat n'écrit donc rien. Tout passe par `ChatRepository` ; les écrans n'appellent jamais Firebase directement.

## Comment c'est construit (3 couches)

- **Repository** (`chat_repository.dart`) : le seul endroit qui parle à Firestore. Il envoie les messages, surveille les conversations et les messages, marque comme lu, et transforme les erreurs Firebase en une petite liste `ChatError`.
- **Controller** (`chat_controller.dart`) : providers Riverpod. Ils donnent la liste de conversations en direct, les messages en direct (les 50 derniers), le total de non lus pour le badge, et `sendChatMessage` avec une limite d'attente de 8 secondes.
- **Écrans** : la liste et l'écran de chat affichent seulement l'état et appellent le controller.

## Questions probables et réponses courtes

1. **Comment un message est-il envoyé ?** Un seul lot d'écritures Firestore écrit deux choses ensemble : le message, et le résumé de la conversation (`lastMessage`, `lastMessageAt`, +1 non lu pour l'autre personne). Une conversation ne peut donc jamais afficher un message qui n'existe pas. Pour le premier message, le même `set` crée aussi la conversation.
2. **Comment empêcher un inconnu de lire une conversation ?** Les règles Firestore : seul un utilisateur dont l'uid est dans `participantIds` peut lire la conversation et ses messages. Les messages ne peuvent être ni modifiés ni supprimés (`allow update, delete: if false`). Un message doit être envoyé par l'utilisateur lui-même (`senderId == uid`) et faire au plus 2000 caractères.
3. **Le propriétaire peut-il se parler à lui-même, ou quelqu'un peut-il créer une conversation pour deux autres personnes ?** Non. La règle de création exige que l'identifiant soit `{listingId}_{myUid}`, et la refuse quand le créateur est le propriétaire de l'annonce. Le code lève aussi `ownListing` avant l'envoi.
4. **Que se passe-t-il hors ligne ?** Firestore garde l'écriture dans une file locale. L'écran attend 8 secondes, puis affiche un message « pas de réseau », mais le message n'est pas perdu : il est envoyé au retour du réseau. Limite connue : il n'y a pas de vraie vérification d'internet avant l'envoi.
5. **Comment fonctionne le badge de non lus ?** Chaque conversation a `unread` avec un compteur par utilisateur. Envoyer ajoute 1 pour l'autre personne. Ouvrir le chat remet votre propre compteur à 0 (`markRead`). Le badge de l'icône du chat et de la cloche additionne les compteurs de la même liste en direct, donc aucun second écouteur Firestore n'est ouvert.
6. **Pourquoi la liste est-elle triée dans l'application et pas dans la requête ?** `arrayContains` avec `orderBy` demanderait un index Firestore. Trier dans l'application l'évite, et les listes sont petites.
7. **Pourquoi seulement les 50 derniers messages ?** Pour garder l'écran rapide et peu coûteux en lectures. L'écouteur s'arrête quand l'écran se ferme (`autoDispose`), donc aucun écouteur ne fuit.
8. **Pourquoi `participantIds` est-il toujours `[acheteur, propriétaire]` ?** La règle de modification refuse un changement du tableau, et les tableaux sont comparés dans l'ordre. L'application l'écrit donc toujours dans le même ordre.
9. **Comment gérer l'arabe, le français et l'anglais mélangés ?** Chaque message a sa propre direction de texte, donnée par sa première lettre (`textDirectionFor`, règle Unicode du « premier caractère fort »). « Salut مرحبا » va de gauche à droite, « مرحبا Salut » de droite à gauche. Les chiffres et les emojis suivent la valeur par défaut.
10. **Comment les erreurs sont-elles affichées ?** Le repository associe les codes Firebase à `ChatError` (non connecté, propre annonce, message trop long, pas de réseau, permission refusée, inconnue). Les écrans les transforment en textes traduits en anglais, français et arabe.
11. **Comment est-ce testé ?** Des tests unitaires pour les modèles, l'analyse de l'identifiant, la direction du texte et le tri, et des tests de widget pour l'écran de chat. J'ai aussi testé sur un vrai téléphone avec deux comptes.

## Limites honnêtes (à dire avant qu'on les demande)

- Pas de notifications push. L'alerte est dans l'application uniquement (elle est créée après un envoi réussi, voir le point d'accroche VST-50 dans `sendChatMessage`). Le push est un travail futur (VST-135).
- Pas de vérification d'internet avant l'envoi ; le message attend dans la file.
- Les messages sont du texte uniquement (pas de photos) et ne peuvent être ni modifiés ni supprimés.
- La règle de modification permet à un participant de changer les compteurs de non lus : les compteurs ne sont donc pas à l'épreuve de la falsification. C'est acceptable pour ce projet, et une Cloud Function réglerait le problème.
- Le chat React Native (VST-45, PR #102) existe mais n'est pas fusionné avant le gel du code.

## Si vous ne connaissez pas la réponse

Dire : « Cette partie est dans `chat_repository.dart`, je peux vous montrer les lignes exactes. » Puis ouvrir le fichier. Ne pas deviner.
