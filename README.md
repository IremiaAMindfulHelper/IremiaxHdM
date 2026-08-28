## 1. Matrikelnummern und Studiengang

**Ersetzt** die bestehende Liste unter „Projektmitglieder":

```markdown
## Projektmitglieder

| Name | Matrikelnummer | Studiengang |
| --- | --- | --- |
| Kerem Sarica | 45756 | Mobile Medien |
| Semih Akcay | 45852 | Mobile Medien |
| Yusuf Altun | 46082 | Mobile Medien |

**Betreuung:** Prof. Dr. Ansgar Gerlicher
```

---

## 2. Linksammlung

**Neu, direkt nach den Projektmitgliedern.** Das ist der wichtigste Punkt. Gerlicher schreibt, das
Repository sei *„the central entry point"* und solle *„everything needed to understand, set up, and
evaluate your work"* enthalten.

```markdown
## Projektmaterialien

| Material | Link |
| --- | --- |
| Projektdokumentation (PDF) | [docs/Projektdokumentation.pdf](docs/Projektdokumentation.pdf) |
| Demo-Video | *hier Link einsetzen* |
| Finale Präsentation (PDF) | *hier Link einsetzen* |
| Umfrage-Auswertung (PDF) | *hier Nextcloud-Link einsetzen* |
| Figma, Design und Prototyp | *hier Link einsetzen* |
| FigJam, Affinity Map und Nutzer-Cluster | *hier Link einsetzen* |
| Confluence, Projekt-Space | *hier Link einsetzen* |
| Technische Dokumentation | [docs/](docs/) |

Rohdaten aus Umfrage und Nutzertests liegen aus Datenschutzgründen nicht in diesem öffentlichen
Repository, sondern in der HdM-Nextcloud.
```

---

## 3. Abgabestand und bekannte Limitationen

**Ergänzt** Schritt 1 des Setups um die Branch-Angabe:

```markdown
### 1. Repository klonen

git clone https://github.com/IremiaAMindfulHelper/IremiaxHdM.git
cd IremiaxHdM
git checkout insights-integration/base

Der Abgabestand liegt auf dem Branch `insights-integration/base`.
```

**Neu**, als eigener Abschnitt nach „4. Projekt öffnen und Ausführen":

```markdown
### Bekannte Limitationen beim Setup

Ein Build auf einem physischen iPhone braucht ein eigenes Apple-Developer-Team in den
Signing-Einstellungen des Targets. Im Simulator ist das nicht nötig. Ein vollautomatisches
One-Click-Setup ist damit nicht möglich.

Die Dateien unter `secrets/` sind mit git-crypt verschlüsselt, weil das Repository öffentlich ist.
Ohne Schlüssel sind sie nicht lesbar, für einen Debug-Build werden sie aber nicht gebraucht.

Das erste Gradle-Sync dauert mehrere Minuten, weil dabei das XCFramework erzeugt wird.

Docker beziehungsweise docker-compose gibt es nicht, das ist bei einer mobilen KMP-App nicht
sinnvoll.
```

---

## 4. Verweis auf die technische Dokumentation

**Neu**, ans Ende vor die Lizenz. Die acht Dokumente liegen bereits im Repo, werden im README aber
nirgends erwähnt.

```markdown
## Technische Dokumentation

Unter [`docs/`](docs/) liegen acht Dokumente für alle, die das Projekt fortführen:

| Dokument | Inhalt |
| --- | --- |
| [01-architektur.md](docs/01-architektur.md) | Schichten, Datenfluss, Modulgrenzen |
| [02-shared-modul.md](docs/02-shared-modul.md) | DAO, Repository, Controller, SQLDelight |
| [03-android.md](docs/03-android.md) | Compose-Aufbau, ViewModels, Theme |
| [04-ios.md](docs/04-ios.md) | SwiftUI, Observables, Flow-Interop |
| [05-feature-hinzufuegen.md](docs/05-feature-hinzufuegen.md) | Anleitung von der Tabelle bis zur Oberfläche |
| [06-lokalisierung.md](docs/06-lokalisierung.md) | moko-resources, Basissprache |
| [07-build-und-auslieferung.md](docs/07-build-und-auslieferung.md) | CI, TestFlight, Play Store |
| [08-codequalitaet.md](docs/08-codequalitaet.md) | bekannte technische Schulden, Übergabe |
```

---

## Optional, falls noch Zeit ist

Ein kurzer Abschnitt darüber, was in diesem Semester entstanden ist. Macht auf den ersten Blick
sichtbar, was euer Beitrag war und was schon da war.

```markdown
## Was in diesem Semester entstanden ist

Journal mit zweistufiger Erfassung und zwei Eintragstypen, Monatsgarten mit Baum für belastende
Ereignisse und Beet für Journaleinträge, ein lokal rechnender Insights-Algorithmus über ein
rollierendes 30-Tage-Fenster, das Design-System als Token-Schicht auf beiden Plattformen und die
iOS-Parität in SwiftUI.

Umfang: rund 15.000 Zeilen über 176 Dateien, 15 Unit-Tests, 174 neue lokalisierte Textbausteine.
```
