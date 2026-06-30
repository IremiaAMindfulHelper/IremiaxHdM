# Handoff – Iremia Journal/Garten (Session-Übergabe)

> Zweck: Nahtloses Weiterarbeiten nach Kontowechsel. Stand: 2026-07-01.
> Branch: `insights-integration/SIC-24-journal-screen`

---

## 0. NEU: Großer Bugfix/Feature-Durchlauf abgeschlossen (P1–P3)

Die komplette priorisierte Liste (P1 kritisch, P2 Garten/Lottie, P3 Usability)
ist umgesetzt und committet. Reihenfolge der neuen Commits (oben = neuste):

- `adf0466` fix(journal): sichtbarer Slider-Thumb + ganzflächig klickbare Garten-Card (P3.1/3.3)
- `76a7110` feat(episode): reichere Cards (Datum/Vorschau/Emoji/Intensität) + Detail/Bearbeiten (P3.5, beide)
- `0cbbd2e` feat(ios): Lottie-Parität (Growth+Ambient Fullscreen, Position), Metadaten, Garten nach Speichern (P2.1/2.3/2.4)
- `ca37c50` feat(episode): DB-Migration Metadaten + Android-Erfassung + Erfolgs-Animation (P2.6 + Querschnitt)
- `df3aa75` fix(garden): Untergrundfarbe an Sprite-Gras (#A8C060) + mehr Blumen (P2.2/2.5)
- `f8d9728` feat(journal): echte Umlaute, Episode-Benennung, iOS-Add-Button (P1.3)
- `9203408` fix(journal): Kalender zuverlässig zuklappbar (P1.1)
- `9c2b13e` fix(journal): Reflexions-Textfeld lesbar (P1.2, Android)

**Verifiziert hier:** Android (`:composeApp:compileDebugKotlin`) + shared (alle iOS-Targets)
kompilieren; Unit-Tests grün (GardenRandomizerTest inkl. neuem Gewichtungs-Test).
XCFramework neu gebaut + nach `iosApp/` kopiert.

**NOCH OFFEN (nur lokal möglich):**
1. **iOS-Build in Xcode**: `cd iosApp && pod install` (zieht neu `lottie-ios ~> 4.4`),
   dann in Xcode bauen. Konnte hier nicht verifiziert werden (kein Xcode/CocoaPods).
   - Hinweis: Im Plan war „dotLottie-ios (LottieFiles)" gewählt; umgesetzt wurde
     `lottie-ios 4.x` (spielt `.lottie` nativ, deutlich robustere CocoaPods-Unterstützung).
     Falls bewusst die LottieFiles-Rust-Lib gewünscht ist: in `iosApp/Podfile` tauschen
     und `LottieFileView` in `Garden/LottieViews.swift` anpassen.
2. Manuell prüfen: Kalender auf/zu, Textfarbe Reflexion, Umlaute, Garten-Farbe,
   Pflanz-Animation an korrekter Kachel, Ambient Fullscreen ohne Clipping,
   Card-Inhalte, Episode-Detail/Bearbeiten, nach Speichern Wachstum + „Im Garten ansehen".
3. Bewusst NICHT angefasst: ASCII-Umlaute in Nicht-Journal-Bereichen (Breathing,
   Calculation, Diary). Bei Bedarf separater Commit.

---

## 1. Was davor erledigt & committet ist (frühere Session)

Vier Garten-Bugs gefixt, je ein Commit (deutsch, **ohne** Co-Authored-By – so vom User gewünscht):

| Commit | Inhalt |
|--------|--------|
| `150c7e1` | Grasflaeche vereinheitlicht zu nahtloser Wiese (Android + iOS) – ein einheitlicher Grünton statt Schachbrett |
| `02eb897` | Stabile, append-only Baum-Platzierung (`entryIds.sorted()` im Randomizer) + `entryId` an `GardenTile`; Controller erkennt Neu-Eintrag über hinzugekommene id. Unit-Tests (`GardenRandomizerTest`, 5 Stück, grün) |
| `f0f14d1` | Tap auf Baum → Sheet mit Datum + Inhalt des Eintrags (`selectedEntry` im Controller-State). Android: In-Layout-Sheet mit Scrim; iOS: natives `.sheet`. Neue Strings `garden_entry_sheet_title/_empty` |
| `dc6cade` | Wachstums-Animation beim Pflanzen repariert. Android: `LaunchedEffect` wartet auf geladene Compottie-Composition. iOS: native Scale/Fade-Wachstumsanimation (provisorisch – wird in P2.1 durch echte Lotties ersetzt) |

Working tree ist sauber. `Shared.xcframework` wurde neu gebaut & nach `iosApp/` kopiert (nicht git-tracked).

---

## 2. Offener Plan (vom User noch NICHT final freigegeben)

Vollständiger Plan liegt in:
`/Users/kero61/.claude/plans/kontext-wichtige-vorab-anweisung-happy-wigderson.md`

### Bestätigte Entscheidungen des Users (wichtig!)
- **iOS Lottie:** `dotLottie-ios` (LottieFiles) als CocoaPod, spielt `.lottie` nativ. → Podfile-Änderung + `pod install` nötig; Xcode-Build muss der User selbst verifizieren.
- **Episode-Metadaten:** volle **DB-Migration** – Stärke/Ort/Aktivität/Stimmung speichern; Einträge **anzeigbar + bearbeitbar** machen (neuer Episode-Detail/Edit-Screen).
- **Nach Speichern:** Wachstums-Animation im **Erfolgs-Screen** abspielen (App-Kontext bleibt) + Button „Im Garten ansehen".
- **Add-Button iOS:** zusätzlich zum kleinen Plus einen **richtigen, beschrifteten Button** wie Android (sticky `PrimaryButton` existiert zwar – User will einen klaren Add-Button im „Letzte Episoden"-Bereich).

### Aufgabenliste nach Priorität
**P1 – kritisch**
- 1.1 Kalender zuklappbar: Tap-Target des Handles unzuverlässig. iOS `ExpandHandleView` → `.contentShape(Rectangle())`; Header (Monat/Jahr) als zweite Toggle-Fläche. Android `ExpandHandle` analog, Scroll-Überlagerung prüfen. (`JournalCalendarView.swift`, `JournalCalendar.kt`)
- 1.2 Textfeld weiß-auf-weiß (**nur Android**): `EpisodeStepScreens.kt` Reflection-`OutlinedTextField` braucht explizite `colors` (Text `Ink900`, Placeholder `Gray400`). iOS ist ok.
- 1.3 Sprache: iOS `JournalPrototypeStrings.swift` „ae/oe/ue/ss" → echte Umlaute. „Notizen/Notiz" → „Episode/Episoden" (user-facing, **Daten-Layer `Note*` bleibt**). iOS beschrifteten Add-Button ergänzen (in `RecentNotesSectionView.swift`), Android spiegeln.

**P2 – Garten/Lottie/Logik**
- 2.1 iOS Lottie-Parität (Growth + Ambient) via dotLottie-ios. moko `FileResource` auf iOS → `bundle.url(forResource:withExtension:)`. Ambient-Pool wie Android (`AmbientSurpriseOverlay.kt`: Leaves 30/Birds 25/Autumn 20/Butterflies 15/PaperPlane 8/Deer 5).
- 2.2 Garten-Untergrundfarbe exakt = Hellgrün der Tiles (Android `GrassTop`, iOS `grassTop`).
- 2.3 Ambient-Overlay **fullscreen** (auf Root-Ebene des Garten-Screens, nicht in der Card).
- 2.4 Pflanz-Position == Sprite-Position (iOS neue GrowthView muss exakt `center(col,row)` + gleichen Anker nutzen). Android bereits konsistent.
- 2.5 Randomizer-Gewichtung (shared `GardenRandomizer.assignPlantType` + `drawDecoration`): Bäume + **Blumenbeete** deutlich häufiger, Büsche/Steine seltener. Aktuell 80/20 Bäume/Blumen → z.B. 65/35; leere Tiles mehr Blumen.
- 2.6 Erfolgs-Screen-Animation + „Im Garten ansehen"-Button. `markNewlyPlanted` beim Speichern setzen.

**Querschnitt (Basis für 2.6/3.4/3.5):** Episode-Metadaten persistieren
- `Note.sq`: Spalten `strength/place/activity/bodySignals/moodBefore/moodAfter` + Migration (`.sqm`, NULL-Defaults).
- `Note.kt`, `NoteDao`, `NoteRepository`, `NotesController`: Felder + `insert`/`update`/`add(Async)` erweitern.
- `EpisodeCaptureFlow` (beide): Draft-Daten an `onSave` durchreichen (statt nur `note`).
- Episode-Detail/Bearbeiten-Screen (beide): füllt bestehende `onNoteClick`-TODOs.

**P3 – Usability**
- 3.1 Garten-Container ganzflächig klickbar (bereits ~ok, nur verifizieren).
- 3.2 Kalender-Buttons ≥ 44×44 dp/pt (Heute-Button, Add-Icon, Handle).
- 3.3 Slider-Thumb sichtbar (kontrast + Drop-Shadow). Android Custom-Thumb; iOS Overlay-Thumb.
- 3.4 Benennung „Episode" vereinheitlichen (siehe 1.3).
- 3.5 Episoden-Cards erweitern: Kontext-Emoji, Intensitäts-Indikator, Datum/Uhrzeit, ~50-Zeichen-Vorschau (braucht Querschnitt-Migration).

### Empfohlene Commit-Reihenfolge
1) P1.2 Textfeld → 2) P1.1 Kalender → 3) P1.3 Umlaute+Benennung+iOS-Button →
4) P2.2 Farbe + P2.5 Randomizer → 5) DB-Migration (Querschnitt) → 6) P2.6 Erfolgs-Animation →
7) P2.1 iOS Lottie + P2.3 Fullscreen + P2.4 Position → 8) P3.5 Cards + Detail/Edit → 9) P3.1/3.2/3.3.

---

## 3. Wichtige Projekt-Konventionen (aus dieser Session gelernt)
- **Commit-Messages:** Deutsch, kurz, Conventional-Prefix, **KEIN** `Co-Authored-By`-Trailer.
- **Build/Test-Check vor Commit:** `./gradlew :composeApp:compileDebugKotlin :shared:testDebugUnitTest`.
- Nach String-Änderung: `./gradlew :shared:generateMRcommonMain`. Nach `.sq`-Änderung: `:shared:generateSqlDelightInterface`.
- iOS: `:shared:assembleSharedXCFramework :shared:copyXCFrameworkToIosApp`, dann **User** macht `pod install` + Xcode-Build (hier nicht verifizierbar).
- Architektur strikt: SQLDelight → Domain → DAO → Repository → Controller(StateFlow) → ViewModel/Observable → stateless UI. Strings nur via `SharedRes`/moko.

---

## 4. Bekannte Einschränkung
Der **Xcode-Build kann in dieser Umgebung nicht verifiziert werden** (kein Xcode/CocoaPods). iOS-Swift wird gegen die neu gebaute `Shared.xcframework` + bestätigte Design-Tokens geschrieben; finale Verifikation läuft beim User.

---

## 5. Sofort-Einstieg im neuen Konto
1. Diese Datei + den Plan (`~/.claude/plans/kontext-...-happy-wigderson.md`) lesen.
2. Plan vom User freigeben lassen (war noch offen).
3. Mit P1.2 (Android-Textfeld) als kleinem, isoliertem ersten Commit starten.
