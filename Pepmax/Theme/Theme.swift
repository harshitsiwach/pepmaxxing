import SwiftUI

// MARK: - Liquid Glass Theme System

enum AppTheme {
    case dark, light
}

struct LiquidGlassTheme {
    let background: Color
    let surface: Color
    let surfaceElevated: Color
    let glassLayer: Color
    let glassBorder: Color
    let primary: Color
    let primarySoft: Color
    let primaryGlow: Color
    let text: Color
    let textMuted: Color
    let border: Color
    let success: Color
    let warning: Color
    let error: Color
    
    // Glass card style
    let cardCornerRadius: CGFloat = 16
    let cardBorderWidth: CGFloat = 1
    let cardShadowRadius: CGFloat = 16
    let cardShadowY: CGFloat = 8
    
    static let dark = LiquidGlassTheme(
        background: Color(hex: "0A0A0F"),
        surface: Color(hex: "1E1E28", opacity: 0.6),
        surfaceElevated: Color(hex: "282837", opacity: 0.7),
        glassLayer: Color.white.opacity(0.08),
        glassBorder: Color.white.opacity(0.15),
        primary: Color(hex: "FF2D55"),
        primarySoft: Color(hex: "FF6B82"),
        primaryGlow: Color(hex: "FF2D55", opacity: 0.3),
        text: .white,
        textMuted: Color.white.opacity(0.5),
        border: Color.white.opacity(0.12),
        success: Color(hex: "00FF87"),
        warning: Color(hex: "FFB800"),
        error: Color(hex: "FF2D55")
    )
    
    static let light = LiquidGlassTheme(
        background: Color(hex: "F5F5F7"),
        surface: Color.white.opacity(0.7),
        surfaceElevated: Color.white.opacity(0.85),
        glassLayer: Color.white.opacity(0.25),
        glassBorder: Color.black.opacity(0.1),
        primary: Color(hex: "FF2D55"),
        primarySoft: Color(hex: "FF6B82"),
        primaryGlow: Color(hex: "FF2D55", opacity: 0.15),
        text: Color(hex: "1A1A1F"),
        textMuted: Color(hex: "1A1A1F", opacity: 0.5),
        border: Color.black.opacity(0.08),
        success: Color(hex: "00C853"),
        warning: Color(hex: "FF9500"),
        error: Color(hex: "FF2D55")
    )
}

// MARK: - Color Extension

extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Typography

struct AppTypography {
    static let h1 = Font.system(size: 32, weight: .bold)
    static let h2 = Font.system(size: 24, weight: .bold)
    static let h3 = Font.system(size: 20, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let bodySmall = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let mono = Font.system(size: 14, weight: .regular, design: .monospaced)
}

// MARK: - Theme Environment Key

struct ThemeKey: EnvironmentKey {
    static let defaultValue: LiquidGlassTheme = .dark
}

struct IsDarkModeKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var theme: LiquidGlassTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
    
    var isDarkMode: Bool {
        get { self[IsDarkModeKey.self] }
        set { self[IsDarkModeKey.self] = newValue }
    }
}

// MARK: - Category Colors

struct CategoryColors {
    static func color(for category: String) -> Color {
        switch category.lowercased() {
        case let c where c.contains("gh secretagogue"), let c where c.contains("ghrh"):
            return Color(hex: "6C5CE7")
        case let c where c.contains("glp-1"), let c where c.contains("glp"):
            return Color(hex: "00B894")
        case let c where c.contains("gut"), let c where c.contains("repair"), let c where c.contains("tissue"):
            return Color(hex: "0984E3")
        case let c where c.contains("neuro"), let c where c.contains("cognitive"):
            return Color(hex: "FDCB6E")
        case let c where c.contains("immune"):
            return Color(hex: "E17055")
        case let c where c.contains("pomc"), let c where c.contains("sexual"):
            return Color(hex: "FF2D55")
        case let c where c.contains("bone"), let c where c.contains("musculoskeletal"):
            return Color(hex: "55E6C1")
        case let c where c.contains("metabolic"), let c where c.contains("growth"):
            return Color(hex: "F97F51")
        case let c where c.contains("antimicrobial"):
            return Color(hex: "58B19F")
        case let c where c.contains("reproductive"):
            return Color(hex: "E056A0")
        case let c where c.contains("hematopoietic"), let c where c.contains("epo"):
            return Color(hex: "C44569")
        case let c where c.contains("peptide mixture"):
            return Color(hex: "786FA6")
        case let c where c.contains("telomerase"), let c where c.contains("copper"):
            return Color(hex: "F8A5C2")
        case let c where c.contains("cardiovascular"):
            return Color(hex: "E74C3C")
        default:
            return Color(hex: "A29BFE")
        }
    }
    
    static func icon(for category: String) -> String {
        switch category.lowercased() {
        case let c where c.contains("gh secretagogue"), let c where c.contains("ghrh"):
            return "arrow.up.circle.fill"
        case let c where c.contains("glp"):
            return "scalemass.fill"
        case let c where c.contains("gut"), let c where c.contains("repair"), let c where c.contains("tissue"):
            return "bandage.fill"
        case let c where c.contains("neuro"), let c where c.contains("cognitive"):
            return "brain.head.profile"
        case let c where c.contains("immune"):
            return "shield.checkered"
        case let c where c.contains("pomc"), let c where c.contains("sexual"):
            return "heart.fill"
        case let c where c.contains("bone"), let c where c.contains("musculoskeletal"):
            return "figure.strengthtraining.traditional"
        case let c where c.contains("metabolic"), let c where c.contains("growth"):
            return "flame.fill"
        case let c where c.contains("antimicrobial"):
            return "allergens.fill"
        case let c where c.contains("reproductive"):
            return "leaf.fill"
        case let c where c.contains("hematopoietic"), let c where c.contains("epo"):
            return "drop.fill"
        case let c where c.contains("cardiovascular"):
            return "heart.circle.fill"
        default:
            return "pills.fill"
        }
    }
}
