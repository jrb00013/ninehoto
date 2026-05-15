import SwiftUI

struct DebugView: View {
    @State private var logs: [String] = []
    @State private var showPerformanceReport = false
    @State private var showFeatureFlags = false
    @State private var showAnalytics = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Runtime Info") {
                    HStack {
                        Text("App Version")
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
                    
                    HStack {
                        Text("Swift Version")
                        Spacer()
                        Text("5.9")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Performance") {
                    Button("Show Performance Report") {
                        showPerformanceReport = true
                    }
                    
                    Button("Clear Performance Data") {
                        PerformanceMonitor.shared.clear()
                    }
                }
                
                Section("Debug Features") {
                    Button("Toggle Feature Flags") {
                        showFeatureFlags = true
                    }
                    
                    Button("View Analytics Events") {
                        showAnalytics = true
                    }
                    
                    Button("Clear Analytics") {
                        AnalyticsService.shared.clearEvents()
                    }
                    
                    Button("Clear All Caches") {
                        CacheManager.shared.clearAll()
                        Task {
                            await ThumbnailCache.shared.clear()
                        }
                    }
                }
                
                Section("Simulator Tools") {
                    Button("Simulate Low Memory") {
                        // Simulate memory warning
                    }
                    
                    Button("Simulate Network Error") {
                        // Simulate network error
                    }
                }
                
                Section("Logs") {
                    Button("Export Logs") {
                        exportLogs()
                    }
                    
                    Button("Clear Logs") {
                        logs.removeAll()
                    }
                }
            }
            .navigationTitle("Debug")
            .sheet(isPresented: $showPerformanceReport) {
                PerformanceReportSheet()
            }
            .sheet(isPresented: $showFeatureFlags) {
                DebugFeatureFlagsSheet()
            }
            .sheet(isPresented: $showAnalytics) {
                AnalyticsSheet()
            }
        }
    }
    
    private func exportLogs() {
        // Export logs to file
    }
}

struct PerformanceReportSheet: View {
    @State private var stats: [PerformanceStats] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(stats, id: \.label) { stat in
                    Section(stat.label) {
                        LabeledContent("Count", value: "\(stat.count)")
                        LabeledContent("Average", value: String(format: "%.2fms", stat.averageMs))
                        LabeledContent("Min", value: String(format: "%.2fms", stat.minMs))
                        LabeledContent("Max", value: String(format: "%.2fms", stat.maxMs))
                        LabeledContent("Median", value: String(format: "%.2fms", stat.medianMs))
                    }
                }
            }
            .navigationTitle("Performance Report")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
            .onAppear {
                stats = PerformanceMonitor.shared.getAllStatistics()
            }
        }
    }
}

struct DebugFeatureFlagsSheet: View {
    @State private var flags: [String: Bool] = [:]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(FeatureName.allCases), id: \.self) { name in
                    Toggle(name.rawValue, isOn: Binding(
                        get: { flags[name.rawValue] ?? false },
                        set: { newValue in
                            flags[name.rawValue] = newValue
                            FeatureFlags.shared.setFeature(name.rawValue, enabled: newValue)
                        }
                    ))
                }
            }
            .navigationTitle("Feature Flags")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
            .onAppear {
                for feature in FeatureName.allCases {
                    flags[feature.rawValue] = FeatureFlags.shared.isFeatureEnabled(feature.rawValue)
                }
            }
        }
    }
}

struct AnalyticsSheet: View {
    @State private var events: [AnalyticsEvent] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.name)
                            .font(.headline)
                        Text(event.timestamp.formatted)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
            .onAppear {
                events = AnalyticsService.shared.getEvents()
            }
        }
    }
}