import SwiftUI
import UIKit

struct AppColors {
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let accent = Color("Accent")
    static let background = Color("Background")
    static let surface = Color("Surface")
    static let error = Color("Error")
    static let success = Color("Success")
    static let warning = Color("Warning")
    
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    static let separator = Color(UIColor.separator)
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    
    static let destructiveRed = Color.red
    static let keepGreen = Color.green
    static let swipeYellow = Color.yellow
}

struct AppFonts {
    static let title = Font.largeTitle
    static let headline = Font.headline
    static let body = Font.body
    static let caption = Font.caption
    static let footnote = Font.footnote
    
    static func custom(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

struct AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct AppCornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
    static let circular: CGFloat = 9999
}

struct AppShadow: ViewModifier {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(opacity), radius: radius, x: x, y: y)
    }
}

extension View {
    func appShadow(radius: CGFloat = 8, x: CGFloat = 0, y: CGFloat = 4, opacity: Double = 0.1) -> some View {
        modifier(AppShadow(radius: radius, x: x, y: y, opacity: opacity))
    }
    
    func cardStyle() -> some View {
        self
            .background(Color.secondarySystemBackground)
            .cornerRadius(AppCornerRadius.large)
            .appShadow()
    }
    
    func elevatedCard() -> some View {
        self
            .background(Color.secondarySystemBackground)
            .cornerRadius(AppCornerRadius.large)
            .appShadow(radius: 12, opacity: 0.15)
    }
}