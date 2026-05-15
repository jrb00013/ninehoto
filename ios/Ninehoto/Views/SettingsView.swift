import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("thumbnailQuality") private var thumbnailQuality = 1
    @AppStorage("preferredSortOrder") private var sortOrder = 0

    @State private var showResetConfirmation = false
    @State private var showClearCacheConfirmation = false

    private let preferences = PreferencesManager.shared

    var body: some View {
        NavigationView {
            List {
                Section("Preferences") {
                    Toggle(LocalizationManager.shared.translate(.hapticFeedback), isOn: $hapticFeedbackEnabled)

                    Picker(LocalizationManager.shared.translate(.thumbnailQuality), selection: $thumbnailQuality) {
                        Text(LocalizationManager.shared.translate(.qualityLow)).tag(0)
                        Text(LocalizationManager.shared.translate(.qualityMedium)).tag(1)
                        Text(LocalizationManager.shared.translate(.qualityHigh)).tag(2)
                    }

                    Picker(LocalizationManager.shared.translate(.sortOrder), selection: $sortOrder) {
                        Text(LocalizationManager.shared.translate(.sortNewestFirst)).tag(0)
                        Text(LocalizationManager.shared.translate(.sortOldestFirst)).tag(1)
                        Text(LocalizationManager.shared.translate(.sortRecentlyAdded)).tag(2)
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Text(LocalizationManager.shared.translate(.resetStatistics))
                    }

                    Button(role: .destructive) {
                        showClearCacheConfirmation = true
                    } label: {
                        Text(LocalizationManager.shared.translate(.clearCache))
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.buildNumber)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Debug") {
                    NavigationLink("Feature Flags") {
                        FeatureFlagsView()
                    }

                    NavigationLink("Statistics") {
                        StatisticsDetailView()
                    }
                }
            }
            .navigationTitle(LocalizationManager.shared.translate(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset Statistics", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    preferences.resetStatistics()
                }
            } message: {
                Text("This will reset all session statistics. This action cannot be undone.")
            }
            .alert("Clear Cache", isPresented: $showClearCacheConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    Task {
                        await ThumbnailCache.shared.clear()
                    }
                }
            } message: {
                Text("This will clear all cached thumbnails. They will be reloaded as needed.")
            }
        }
    }
}

struct FeatureFlagsView: View {
    @State private var flags: [String: Bool] = [:]

    var body: some View {
        List {
            ForEach(Array(FeatureName.allCases), id: \.self) { name in
                Toggle(name.rawValue, isOn: binding(for: name))
            }
        }
        .navigationTitle("Feature Flags")
        .onAppear {
            loadFlags()
        }
    }

    private func binding(for feature: FeatureName) -> Binding<Bool> {
        Binding(
            get: { flags[feature.rawValue] ?? false },
            set: { newValue in
                flags[feature.rawValue] = newValue
                FeatureFlags.shared.setFeature(feature.rawValue, enabled: newValue)
            }
        )
    }

    private func loadFlags() {
        for feature in FeatureName.allCases {
            flags[feature.rawValue] = FeatureFlags.shared.isFeatureEnabled(feature.rawValue)
        }
    }
}

extension FeatureName: CaseIterable {}

struct StatisticsDetailView: View {
    @State private var stats: SessionStatistics = .empty

    var body: some View {
        List {
            Section("All Time") {
                LabeledContent("Total Swipes", value: "\(stats.swipeCount)")
                LabeledContent("Deleted", value: "\(stats.deleteCount)")
                LabeledContent("Kept", value: "\(stats.keepCount)")
                LabeledContent("Delete Rate", value: String(format: "%.1f%%", stats.deleteRate))
                LabeledContent("Total Duration", value: stats.formattedDuration)
            }
        }
        .navigationTitle("Statistics")
        .onAppear {
            stats = StatisticsTracker.shared.getTotalStatistics()
        }
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}