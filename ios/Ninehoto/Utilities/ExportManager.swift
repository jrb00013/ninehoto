import Foundation

final class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    enum ExportFormat {
        case json
        case csv
        case text
    }
    
    struct ExportData {
        let filename: String
        let content: String
        let format: ExportFormat
    }
    
    func exportStatistics(_ statistics: SessionStatistics, format: ExportFormat) -> ExportData? {
        switch format {
        case .json:
            return exportJSON(statistics)
        case .csv:
            return exportCSV(statistics)
        case .text:
            return exportText(statistics)
        }
    }
    
    private func exportJSON(_ statistics: SessionStatistics) -> ExportData? {
        guard let data = try? JSONEncoder().encode(statistics),
              let jsonString = String(data: data, encoding: .utf8) else { return nil }
        
        return ExportData(
            filename: "statistics_\(Date().timeIntervalSince1970).json",
            content: jsonString,
            format: .json
        )
    }
    
    private func exportCSV(_ statistics: SessionStatistics) -> ExportData {
        let csv = """
        Swipe Count,Delete Count,Keep Count,Session Date,Duration (seconds),Avg Swipes/Min
        \(statistics.swipeCount),\(statistics.deleteCount),\(statistics.keepCount),\(statistics.sessionDate),\(statistics.durationSeconds),\(statistics.averageSwipesPerMinute)
        """
        
        return ExportData(
            filename: "statistics_\(Date().timeIntervalSince1970).csv",
            content: csv,
            format: .csv
        )
    }
    
    private func exportText(_ statistics: SessionStatistics) -> ExportData {
        let text = """
        Ninehoto Session Statistics
        ==========================
        
        Total Swipes: \(statistics.swipeCount)
        Deleted: \(statistics.deleteCount)
        Kept: \(statistics.keepCount)
        Delete Rate: \(String(format: "%.1f%%", statistics.deleteRate))
        
        Session Date: \(statistics.sessionDate)
        Duration: \(statistics.formattedDuration)
        Average Swipes/Minute: \(String(format: "%.1f", statistics.averageSwipesPerMinute))
        """
        
        return ExportData(
            filename: "statistics_\(Date().timeIntervalSince1970).txt",
            content: text,
            format: .text
        )
    }
    
    func saveToFile(_ exportData: ExportData) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(exportData.filename)
        
        do {
            try exportData.content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            Logger.shared.error("Failed to save export: \(error)")
            return nil
        }
    }
}