import Foundation

final class PDFGenerator {
    static let shared = PDFGenerator()
    
    private init() {}
    
    func generateStatisticsReport(_ statistics: SessionStatistics) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            let title = "Ninehoto Statistics Report"
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            let dateString = "Generated: \(dateFormatter.string(from: Date()))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            dateString.draw(at: CGPoint(x: 50, y: 80), withAttributes: dateAttributes)
            
            let contentY: CGFloat = 120
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            let lines = [
                "Total Swipes: \(statistics.swipeCount)",
                "Deleted: \(statistics.deleteCount)",
                "Kept: \(statistics.keepCount)",
                "Delete Rate: \(String(format: "%.1f%%", statistics.deleteRate))",
                "Total Duration: \(statistics.formattedDuration)"
            ]
            
            var y = contentY
            for line in lines {
                line.draw(at: CGPoint(x: 50, y: y), withAttributes: contentAttributes)
                y += 25
            }
        }
        
        return data
    }
}

import UIKit