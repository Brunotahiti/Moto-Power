# Notes pour la validation Apple

À coller dans App Store Connect → Informations pour la validation de l'app →
Notes. Rédigées en anglais, langue de l'équipe de validation.

```
Moto Power is a ride dashboard for motorcycles. The phone is mounted on the
handlebar and the app shows GPS speed, distance, acceleration and lean angle
during a ride. No account or login is required. The app is in English by
default; French can be chosen in its settings.

HOW TO TEST
1. Launch the app and accept the one-time safety notice.
2. Tap "Start trip" and allow Location and Motion access.
3. Move with the device (walking is enough): speed, distance and duration
   update. Tilt the device to see the lean gauge move.
4. Lock the screen: the Live Activity shows speed, distance and duration.
5. Tap "End trip" to see the summary. The trip is saved
   and listed under the clock icon at the top of the screen.

BACKGROUND LOCATION
The app declares the "location" background mode and requests When In Use
authorization only. Location updates start when the user taps Start trip and
stop when the user ends the trip. They continue in the background so that a
ride is recorded without gaps while the screen is locked, which is the normal
situation on a handlebar mount. The blue location indicator is shown and the
Live Activity makes the ongoing recording visible. Location is never used
when no trip is being recorded.

DATA
Trips, the garage and emergency contacts stay on the device (SwiftData). The
app has no analytics and no advertising. Three optional features use the
app's public iCloud database (CloudKit), under random identifiers not linked
to the Apple ID:
- Group ride (joined by QR code): position, speed, lean and nickname are
  shared with the riders of that ride and deleted when the user leaves it.
- Live tracking (off by default): position, speed and recent route are
  visible to people who have the user's tracking link.
- Leaderboards (off by default): best acceleration times, nickname and
  motorcycle make and model.
Photos taken with the camera button are saved to the user's photo library
only.

CRASH DETECTION
During a trip the app watches the motion sensors on the device. After a
likely crash it rings and shows a 30-second countdown, then prepares a text
message with the user's location for the emergency contacts they chose. The
user sends the message; nothing is sent automatically. This is why the
"audio" background mode is declared, alongside voice announcements.

SAFETY
A safety notice is shown at first launch. Starting and ending a trip are the
only actions needed, and both are meant to be done while stopped.

ACCELERATION TIMES (0-60 mph, 0-100 km/h, ...)
These are computed automatically from GPS speed whenever the vehicle leaves a
standstill. They need a real vehicle and cannot be reproduced on foot. In the
simulator the app runs in demo mode and shows "Sample data".
```

## Coordonnées à renseigner

Nom, téléphone et adresse e-mail d'une personne joignable pendant la
validation : champs obligatoires dans App Store Connect.
