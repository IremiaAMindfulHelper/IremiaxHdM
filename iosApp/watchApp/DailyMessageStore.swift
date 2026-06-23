import SwiftUI

/// Backs the home-screen "message of the day". Fetches a fresh encouraging,
/// history-aware message from Claude (via the iPhone) every time the home
/// screen appears. The last good message is cached only so something sensible
/// shows instantly while the new one loads; a calm local line is the fallback
/// when the phone is unreachable or on first run.
@MainActor
final class DailyMessageStore: ObservableObject {
    static let shared = DailyMessageStore()

    @Published private(set) var message: String

    static let fallback = "Glad you're here — take one calm breath."

    private let messageKey = "iremia_daily_message"

    private init() {
        message = UserDefaults.standard.string(forKey: messageKey) ?? Self.fallback
    }

    /// Requests a fresh message on every call. On success it replaces and caches
    /// the message; on failure the last good (or fallback) message stays.
    func refresh() async {
        let summary = JourneyStore.shared.journeySummary()
        guard let response = await WatchConnectivityManager.shared.requestDailyMessage(history: summary),
              !response.isEmpty else { return }

        message = response
        UserDefaults.standard.set(response, forKey: messageKey)
    }
}
