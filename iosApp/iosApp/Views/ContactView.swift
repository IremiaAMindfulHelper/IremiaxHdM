import SwiftUI
import ContactsUI

// MARK: - Contact Picker Bridge

struct ContactPickerView: UIViewControllerRepresentable {
    var onPick: (WatchEmergencyContact) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey]
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView
        init(_ parent: ContactPickerView) { self.parent = parent }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let name = [contact.givenName, contact.familyName]
                .filter { !$0.isEmpty }.joined(separator: " ")
            let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
            parent.onPick(WatchEmergencyContact(
                id: Int64(Date().timeIntervalSince1970 * 1000),
                name: name,
                phoneNumber: phone
            ))
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {}
    }
}

// MARK: - Store

final class EmergencyContactsStore: ObservableObject {
    static let shared = EmergencyContactsStore()

    private let defaultsKey = "emergencyContacts"
    @Published var contacts: [WatchEmergencyContact] = []

    private init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let saved = try? JSONDecoder().decode([WatchEmergencyContact].self, from: data) {
            contacts = saved
        }
        PhoneConnectivityManager.shared.sendContacts(contacts)
    }

    func add(_ contact: WatchEmergencyContact) {
        contacts.append(contact)
        persist()
    }

    func remove(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
        PhoneConnectivityManager.shared.sendContacts(contacts)
    }
}

// MARK: - View

struct ContactView: View {
    @ObservedObject private var store = EmergencyContactsStore.shared
    @State private var showingPicker = false

    var body: some View {
        NavigationStack {
            Group {
                if store.contacts.isEmpty {
                    emptyState
                } else {
                    contactList
                }
            }
            .navigationTitle("Notfallkontakte")
            .toolbar {
                if !store.contacts.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button { showingPicker = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingPicker) {
                ContactPickerView { contact in
                    store.add(contact)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 60))
                .foregroundStyle(Color("Primary_500"))
            Text("Keine Notfallkontakte")
                .font(.headline)
            Text("Füge Kontakte hinzu, die im Notfall erreichbar sein sollen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button { showingPicker = true } label: {
                Label("Kontakt hinzufügen", systemImage: "plus")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("Primary_500"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
    }

    private var contactList: some View {
        List {
            ForEach(store.contacts) { contact in
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color("Primary_500"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(.body.weight(.medium))
                        Text(contact.phoneNumber)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: store.remove)
        }
    }
}
