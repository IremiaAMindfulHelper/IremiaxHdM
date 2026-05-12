import SwiftUI

struct ContactsListView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        Group {
            if connectivity.contacts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "person.2.circle")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.iremiaPrimary)
                    Text("No Emergency Contacts")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                List(connectivity.contacts) { contact in
                    Button {
                        if let url = URL(string: "tel://\(contact.phoneNumber)") {
                            WKExtension.shared().openSystemURL(url)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(contact.phoneNumber)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Emergency")
    }
}
