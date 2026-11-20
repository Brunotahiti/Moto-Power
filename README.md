# Moto Power

Application iPhone qui affiche en direct le tableau de bord d'un trajet en
moto, à partir des capteurs du téléphone fixé au guidon : vitesse GPS,
vitesse maximale et moyenne, distance, altitude, durées, poussée
d'accélération, inclinaison, temps 0–100, 0–150, 0–200 et 80–120 km/h.

Chaque trajet terminé est conservé dans l'historique avec son tracé ; deux
trajets peuvent être comparés côte à côte, les records personnels sont
suivis dans le temps, et un trajet se partage en image ou en fichier GPX.
L'app est disponible en français et en anglais, en kilomètres ou en miles,
avec une alerte de vitesse réglable. Le
trajet en cours s'affiche aussi sur l'écran verrouillé et dans la Dynamic
Island, et l'app passe en compteur plein écran quand le téléphone est en
paysage.

## Prérequis

- Xcode 16 ou plus récent
- iOS 17 ou plus récent
- Un iPhone réel pour les capteurs. Dans le simulateur, l'app passe en mode
  démo et affiche « Données d'illustration ».

## Lancer l'app

1. Ouvrir `MotoPower.xcodeproj`.
2. Choisir son équipe dans l'onglet *Signing & Capabilities* des **deux**
   cibles : *MotoPower* et *MotoPowerWidgetsExtension*.
3. Si l'identifiant de bundle de l'app est modifié, celui de l'extension doit
   rester préfixé par lui : `<identifiant de l'app>.Widgets`.
4. Sélectionner le schéma *MotoPower* et lancer sur un iPhone.

> **État de vérification.** La logique (`MotoCore`) est couverte par des
> tests qui passent. L'interface et le projet Xcode sont écrits sans Xcode :
> chaque nouveauté peut demander quelques retouches à la première
> compilation.

## Avant la première mise en service

Moto Power est une app distincte de Scooter Power, avec ses propres
identifiants :

- bundle `com.brunotahiti.MotoPower` (extension `.Widgets`), groupe d'apps
  `group.com.brunotahiti.MotoPower` ;
- conteneur CloudKit `iCloud.com.brunotahiti.MotoPower` : à créer dans le
  compte développeur, puis y importer `cloudkit/schema.ckdb` (classements,
  balade de groupe, suivi en direct) ;
- page de suivi en direct `docs/live/index.html` : coller les deux jetons
  d'API CloudKit du nouveau conteneur dans `TOKENS` ;
- GitHub Pages à activer sur le dossier `docs/` (assistance, confidentialité,
  suivi en direct).

Les visuels (icône, moto de face, pilote vu de dos en trois postures, moto vue
du dessus, vidéo d'ouverture) ont été générés avec Higgsfield.

## Utilisation

1. Fixer le téléphone au guidon, écran face au pilote, en portrait.
2. Moto droite et à l'arrêt, toucher **Démarrer le trajet**. La position
   du téléphone à cet instant sert de zéro pour l'inclinaison et définit
   l'avant de la moto.
3. Si le téléphone a bougé dans son support : menu **•••** puis
   **Recalibrer l'inclinaison**, moto droite.
4. **Terminer le trajet** affiche le résumé et enregistre le trajet.
   L'historique s'ouvre par l'icône d'horloge, visible quand aucun trajet
   n'est en cours.
5. En paysage, démarrer le trajet dans la position où le téléphone restera.

## Ce que mesurent les capteurs

- **Vitesse, distance, altitude** : GPS. Les points dont la précision
  dépasse 50 m sont ignorés ; sans point valide depuis 5 s, la vitesse
  affiche `--`.
- **Durée de roulage** : temps passé au-dessus de 3 km/h.
- **Accélération** : accéléromètre projeté sur l'axe de marche, corrigé par
  la dérivée de la vitesse GPS. « Forte » à partir de ±4 m/s².
- **Temps d'accélération** : départs arrêtés 0–30, 0–50, 0–80, 0–100,
  0–150 et 0–200 km/h (le chrono s'arme à l'arrêt) et reprises lancées 50–90,
  50–100 et 80–120 km/h (le chrono part quand 50 ou 80 km/h est franchi en
  accélérant). Le compteur en direct en montre six : 0–50, 0–100, 0–150,
  0–200, 50–100 et 80–120 ; les autres se lisent dans le résumé et les records.
  En miles, les plages équivalentes sont mesurées en même temps : 0–20, 0–30,
  0–50, 0–60, 0–100 et 0–120 mph, reprises 30–50, 30–60 et 50–75 mph. Une mesure s'annule si la
  vitesse retombe. Le GPS ne donnant qu'un point
  par seconde, les passages sont interpolés : précision d'environ 0,2 s.
- **Inclinaison** : sous 10 km/h, direction de la gravité par rapport à la
  calibration. Au-dessus de 25 km/h, physique du virage : vitesse GPS ×
  vitesse de lacet du gyroscope ÷ gravité. Entre les deux, un mélange.

## Structure

```
MotoCore/      package Swift : calculs, machine à états, formatage (testé)
MotoPower/         app : capteurs, view model, vues SwiftUI, historique
MotoPowerWidgets/  extension : activité en direct et Dynamic Island
Config/           fichiers Info.plist des deux cibles
docs/superpowers/ spécification et plan d'implémentation
```

## Traductions

Le français est la langue source ; les textes français servent de clés. Après
avoir ajouté ou modifié un texte dans le code, ajouter sa traduction anglaise
dans `tools/make_catalogs.py`, puis régénérer les catalogues :

```bash
python3 tools/make_catalogs.py .
```

Le script échoue si un texte du code n'a pas de traduction.

## Tests

```bash
cd MotoCore
swift test
```

`MotoCore` n'importe que Foundation : les tests tournent sous macOS comme
sous Linux.
