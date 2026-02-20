# One Word Journal - App Konzept

## Pitch
365 Wörter. Ein Jahr. Dein ganzes Leben in einem Wort pro Tag.

## Problem
Journalling ist zu aufwendig. 10 Minuten am Tag schreiben? Nix da.
Aber 1 Wort? Das kann jeder.

## Lösung
- Jeden Tag ein Wort eingeben
- Am Ende: 365 Wörter = dein Jahr
- Hübsche Visualisierung
- Export als Poster

## Features (MVP)

### Core
- [ ] Ein-Wort-Eingabe pro Tag
- [ ] Kalender-Übersicht (gefüllte/leere Tage)
- [ ] Lokale Speicherung (kein Server)
- [ ] iCloud Sync (optional)

### Visualisierung
- [ ] Wortwolke am Jahresende
- [ ] Monats-Rückblick
- [ ] "Dominante Stimmung" Analyse (einfach)
- [ ] Export als Bild (Poster-Format)

### Bonus (Phase 2)
- [ ] Farbe pro Tag wählen (Stimmung)
- [ ] Apple Watch Support
- [ ] Widget für Home Screen
- [ ] Trends/Patterns erkennen

## Monetarisierung

- **Preis:** €0,99 einmalig
- **Kein Abo**
- Keine Werbung
- Keine In-App Purchases

## Zielgruppe

- Self-Improvement Interessierte
- Journaling-Neulinge
- Nostalgie-Liebhaber
- Instagram/Twitter "Year in Review" Fans

## Warum das funktioniert

1. **Niedrige Hürde:** 1 Wort = 2 Sekunden
2. **Viral:** "Mein Jahr in 10 Wörtern" Posts
3. **Einmal-Preis:** Keine Abo-Müdigkeit
4. **Offline:** Keine Server-Kosten
5. **SWOT:** Android-Alternative fehlt (iOS zuerst)

## Technical Specs

### Stack
- SwiftUI (iOS 17+)
- Core Data (lokale Speicherung)
- Swift Charts (Visualisierung)
- WidgetKit (Home Screen Widget)

### Data Model
```swift
struct DayEntry: Codable {
    let id: UUID
    let date: Date
    let word: String
    let moodColor: String?  // Optional
}
```

### UI Screens
1. **Today View:** Großes Textfeld, "Teilen" Button
2. **Calendar View:** Monatsraster, grüne/graue Tage
3. **Gallery View:** Alle Wörter als Scroll
4. **Year Review:** Wortwolke, Stats

## Competitive Advantage

| App | Price | USP | Gap |
|-----|-------|-----|-----|
| Day One | €10/Jahr | Full journal | Too much |
| Journey | €5/Jahr | Photo + text | Still too much |
| One Word | Free? | Exactly this? | Doesn't exist well |

## Next Steps

1. [ ] Prototype bauen (Wireframes)
2. [ ] MVP Code schreiben
3. [ ] TestFlight beta
4. [ ] Launch

## Warum 99¢

- Niedrige Einstiegshürde
- "Try it for 99¢" Mentality
- Accumulated: 1000 Downloads = €990
- Passiv: Kein Support/Abo-Management

---

*Erstellt: 2026-02-12*
*Für: Julius*
