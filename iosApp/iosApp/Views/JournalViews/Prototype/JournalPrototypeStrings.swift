import Foundation

@dynamicMemberLookup
struct JournalPrototypeStringProxy {
    private let values: [String: String] = [
        "nav_back": "Zurueck",
        "nav_close": "Schliessen",
        "dialog_cancel": "Abbrechen",
        "dialog_ok": "OK",
        "journal_capture_cta": "Episode festhalten",
        "recent_notes_title": "Letzte Notizen",
        "recent_notes_add": "Notiz hinzufuegen",
        "tree_overview_title": "Baumuebersicht",
        "tree_overview_period": "Dieser Monat",
        "tree_overview_planted": "Baeume gepflanzt",
        "tree_overview_encouragement": "Jeder Eintrag laesst deinen Garten wachsen.",
        "garden_title": "Dein Garten",
        "garden_prev_month": "Vorheriger Monat",
        "garden_next_month": "Naechster Monat",
        "garden_no_entry": "Kein Eintrag",
        "garden_entry_singular": "%1$d Eintrag",
        "garden_entry_plural": "%1$d Eintraege",
        "garden_day_label": "Tag %1$d",
        "garden_month_trees": "%1$d Baeume in diesem Monat",
        "episode_title": "Episode festhalten",
        "episode_next": "Weiter",
        "episode_subtitle": "Halte kurz fest, was passiert ist.",
        "episode_skip_step": "Schritt ueberspringen",
        "episode_when": "Wann war es?",
        "episode_today_time": "Heute um %1$s",
        "episode_strength_label": "Staerke",
        "episode_strength_low": "Leicht",
        "episode_strength_high": "Stark",
        "episode_context_title": "Was war los?",
        "episode_context_where": "Wo warst du?",
        "episode_context_activity": "Was hast du gemacht?",
        "episode_context_body": "Was hast du im Koerper gemerkt?",
        "episode_reflection_title": "Reflexion",
        "episode_reflection_save": "Speichern",
        "episode_reflection_save_no_note": "Ohne Notiz speichern",
        "episode_reflection_prompt": "Was moechtest du festhalten?",
        "episode_reflection_placeholder": "Schreibe ein paar Gedanken auf...",
        "episode_mood_title": "Wie ging es dir?",
        "episode_mood_before": "Vorher",
        "episode_mood_after": "Nachher",
        "episode_saved_title": "Gespeichert",
        "episode_saved_body": "Dein Eintrag wurde festgehalten.",
        "episode_saved_tree_badge": "Ein neuer Baum waechst.",
        "episode_saved_dataset_title": "Dein Datensatz",
        "episode_saved_entries": "Eintraege",
        "episode_saved_goal_hint": "Noch bis %1$d Eintraege fuer bessere Muster.",
        "episode_saved_insights": "Zu den Erkenntnissen",
        "episode_saved_home": "Zur Startseite",
        "episode_place_home": "Zuhause",
        "episode_place_work": "Arbeit",
        "episode_place_public": "Oeffentlich",
        "episode_place_outside": "Draussen",
        "episode_place_commute": "Unterwegs",
        "episode_activity_sleeping": "Schlafen",
        "episode_activity_working": "Arbeiten",
        "episode_activity_sports": "Sport",
        "episode_activity_social": "Sozial",
        "episode_activity_eating": "Essen",
        "episode_activity_traveling": "Reisen",
        "episode_body_heart": "Herzklopfen",
        "episode_body_dizzy": "Schwindel",
        "episode_body_breathless": "Atemnot",
        "episode_body_shaking": "Zittern"
    ]

    subscript(dynamicMember key: String) -> String {
        values[key] ?? key
    }
}

let JournalPrototypeStrings = JournalPrototypeStringProxy()
let PS = JournalPrototypeStrings
