# Iremia — Dokumentation

Einstiegspunkt in die technische Dokumentation. Jedes Dokument ist eigenständig
lesbar; hier steht nur, was wo zu finden ist.

## Wo fange ich an?

| Ich möchte …                                   | Dokument |
| ---------------------------------------------- | -------- |
| verstehen, was die App macht und wie sie aufgebaut ist | [01 Architektur](01-architektur.md) |
| Code im `shared/`-Modul ändern                 | [02 Shared-Modul](02-shared-modul.md) |
| den Android-Client ändern                      | [03 Android](03-android.md) |
| den iOS-Client ändern                          | [04 iOS](04-ios.md) |
| ein neues Feature bauen                        | [05 Feature hinzufügen](05-feature-hinzufuegen.md) |
| Texte ändern oder übersetzen                   | [06 Lokalisierung](06-lokalisierung.md) |
| die App bauen, testen, abgeben                 | [07 Build und Auslieferung](07-build-und-auslieferung.md) |
| wissen, was noch offen ist                     | [08 Codequalität und offene Punkte](08-codequalitaet.md) |

## Die App in drei Sätzen

Iremia begleitet Menschen durch Panikattacken und im Alltag danach. Kernfunktionen
sind Journal-Einträge (geführt oder frei), Atem- und Entspannungsübungen sowie ein
Garten, in dem für Einträge Pflanzen wachsen.

Technisch ist es ein Kotlin-Multiplatform-Projekt: Logik und Daten liegen einmal in
`shared/`, die Oberflächen sind nativ (Jetpack Compose auf Android, SwiftUI auf iOS).

## Inhaltsregel

Nutzertexte bleiben emotional neutral und autonomie-wahrend. Keine Schuldgefühle,
kein Streak-Druck. Das gilt für jeden Text, der in der App sichtbar ist.

## Größenordnung

Stand dieser Dokumentation:

| Bereich | Dateien | Zeilen |
| ------- | ------: | -----: |
| `shared/` (Kotlin) | 52 | ~3.150 |
| `composeApp/` (Android) | 37 | ~6.280 |
| `iosApp/` (Swift) | 68 | ~10.030 |

Der iOS-Teil ist am größten, weil SwiftUI mehr Layout-Code pro Bildschirm braucht
und einige Übungs-Screens dort weiter ausgebaut sind.
