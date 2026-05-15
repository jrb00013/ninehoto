import Foundation

final class DateFormatters {
    static let shared = DateFormatters()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private init() {}
    
    func format(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    func formatShort(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
    
    func formatRelative(_ date: Date) -> String {
        relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    func formatISO8601(_ date: Date) -> String {
        iso8601Formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    func parse(_ string: String) -> Date? {
        dateFormatter.date(from: string)
    }
    
    func parseISO8601(_ string: String) -> Date? {
        iso8601Formatter.date(from: string)
    }
    
    func timeAgo(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        if let month = components.month, month > 0 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        if let week = components.weekOfYear, week > 0 {
            return week == 1 ? "1 week ago" : "\(week) weeks ago"
        }
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        }
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
}

extension Date {
    var formatted: String { DateFormatters.shared.format(self) }
    var formattedShort: String { DateFormatters.shared.formatShort(self) }
    var formattedRelative: String { DateFormatters.shared.formatRelative(self) }
    var formattedISO8601: String { DateFormatters.shared.formatISO8601(self) }
    var formattedTime: String { DateFormatters.shared.formatTime(self) }
    var timeAgo: String { DateFormatters.shared.timeAgo(self) }
}