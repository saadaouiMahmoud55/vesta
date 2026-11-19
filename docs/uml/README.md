# Diagrammes UML de Vesta

Diagrammes de conception en français, dessinés avec Mermaid (les sources `.mmd` sont à côté des images `.png`). Les diagrammes C4 (niveaux 1 à 4) sont dans `docs/c4/`.

| Diagramme | Fichier | Ce qu'il montre |
|---|---|---|
| Cas d'utilisation | `cas-utilisation.png` | Les trois acteurs (invité, utilisateur connecté, propriétaire) et ce qu'ils peuvent faire dans l'application |
| Séquence : connexion | `sequence-connexion.png` | Du formulaire à Firebase Auth, avec les cas d'erreur |
| Séquence : publier une annonce | `sequence-publier-annonce.png` | Compression des photos, validation, écriture groupée annonce, photos et contact |
| Séquence : envoyer un message | `sequence-envoyer-message.png` | Envoi, mise à jour de la conversation, alerte du destinataire en temps réel |
| Modèle de données | `modele-de-donnees.png` | Collections Firestore et leurs relations (voir `docs/data-model.md`) |
| Architecture en couches | `architecture-en-couches.png` | Écran, contrôleur, dépôt, Firebase : la règle commune aux deux applications |
| Flux de travail Git et CI | `pipeline-ci.png` | Du ticket Jira à la fusion, avec les quatre contrôles automatiques |
| Planning | `planning.png` | Sprints 0 à 3, période tampon et jalons (du 1er octobre au 24 novembre) |

Pour redessiner une image : `npx -p @mermaid-js/mermaid-cli mmdc -i cas-utilisation.mmd -o cas-utilisation.png -s 2 -b white`.
