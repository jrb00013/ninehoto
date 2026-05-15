import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var totalStats: SessionStatistics = .empty
    @State private var recentSessions: [SessionStatistics] = []

    var body: some View {
        NavigationView {
            List {
                Section("All Time Statistics") {
                    StatRow(title: "Total Swipes", value: "\(totalStats.swipeCount)")
                    StatRow(title: "Deleted", value: "\(totalStats.deleteCount)", color: .destructiveRed)
                    StatRow(title: "Kept", value: "\(totalStats.keepCount)", color: .keepGreen)
                    Divider()
                    StatRow(title: "Delete Rate", value: String(format: "%.1f%%", totalStats.deleteRate))
                    StatRow(title: "Avg Swipes/Min", value: String(format: "%.1f", totalStats.averageSwipesPerMinute))
                    StatRow(title: "Total Time", value: totalStats.formattedDuration)
                }

                if !recentSessions.isEmpty {
                    Section("Recent Sessions") {
                        ForEach(recentSessions.prefix(10), id: \.sessionDate) { session in
                            SessionRow(session: session)
                        }
                    }
                }
            }
            .navigationTitle(LocalizationManager.shared.translate(.statistics))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadStatistics()
            }
        }
    }

    private func loadStatistics() {
        totalStats = StatisticsTracker.shared.getTotalStatistics()
        recentSessions = StatisticsTracker.shared.getAllSessions()
    }
}

struct StatRow: View {
    let title: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
    }
}

struct SessionRow: View {
    let session: SessionStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.sessionDate.shortFormatted)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                Label("\(session.swipeCount)", systemImage: "hand.swipe")
                Label("\(session.deleteCount)", systemImage: "trash")
                    .foregroundColor(.destructiveRed)
                Label("\(session.keepCount)", systemImage: "checkmark")
                    .foregroundColor(.keepGreen)
                Spacer()
                Text(session.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}