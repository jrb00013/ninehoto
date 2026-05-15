import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor)

                            Text("ninehoto")
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Version \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    .listRowBackground(Color.clear)
                }

                Section("Description") {
                    Text("Swipe left to lose it, right to keep it. Nothing is deleted until you confirm.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Section("Privacy") {
                    PrivacyRow(icon: "lock.shield", title: "On-Device Only", description: "All processing happens locally on your device")
                    PrivacyRow(icon: "eye.slash", title: "No Analytics", description: "No data is sent to any servers")
                    PrivacyRow(icon: "photo", title: "Photo Access", description: "Only accesses photos you explicitly choose to manage")
                }

                Section("Links") {
                    Link(destination: URL(string: "https://github.com/ninehoto/ninehoto")!) {
                        Label("GitHub", systemImage: "link")
                    }

                    Link(destination: URL(string: "https://github.com/ninehoto/ninehoto/blob/main/CONTRIBUTING.md")!) {
                        Label("Contributing", systemImage: "person.badge.plus")
                    }

                    Link(destination: URL(string: "https://github.com/ninehoto/ninehoto/blob/main/CODE_OF_CONDUCT.md")!) {
                        Label("Code of Conduct", systemImage: "heart")
                    }

                    Link(destination: URL(string: "https://github.com/ninehoto/ninehoto/blob/main/SECURITY.md")!) {
                        Label("Security Policy", systemImage: "shield")
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text("MIT License")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(LocalizationManager.shared.translate(.about))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}