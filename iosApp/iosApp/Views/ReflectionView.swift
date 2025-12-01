import SwiftUI

struct ReflectionView: View {
    @StateObject private var vm = MantrasObservable()
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Liste der Mantras
            List {
                if vm.isLoading {
                    HStack {
                        ProgressView()
                        Text("Lade Mantras …")
                    }
                } else if vm.items.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "quote.bubble")
                            .font(.largeTitle)
                            .padding(.top, 24)
                        Text("Noch keine Mantras gespeichert")
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                } else {
                    // Über Indizes iterieren vermeidet Bridging-Irritationen mit KotlinLong
                    ForEach(Array(vm.items.enumerated()), id: \.offset) { _, item in
                        HStack {
                            Text(item.text)
                                .lineLimit(2)
                            Spacer()
                            Button(role: .destructive) {
                                // Falls dein Mantra.id als Int64 exportiert ist, passt das direkt.
                                // Wenn es KotlinLong ist, gib im ViewModel eine passende remove(Item)-Methode.
                                vm.remove(id: item.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)

            // Eingabezeile am Bottom
            HStack(spacing: 12) {
                TextField("Neues Mantra …", text: $vm.inputText)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .focused($inputFocused)
                    .onSubmit {
                        vm.add()
                        inputFocused = false
                    }

                Button {
                    vm.add()
                    inputFocused = false
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .disabled(vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Reflections")
    }
}
