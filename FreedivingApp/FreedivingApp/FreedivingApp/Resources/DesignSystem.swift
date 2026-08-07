import SwiftUI

// MARK: - Colour Palette
extension Color {
    // Backgrounds
    static let appBackground     = Color(hex: "#0A0F1E") // deep navy
    static let appSurface        = Color(hex: "#111827") // slightly lighter navy
    static let appCard           = Color(hex: "#1A2640") // card background

    // Accent
    static let appTeal           = Color(hex: "#0ECDCD") // bright teal
    static let appTealDark       = Color(hex: "#0A8F8F") // darker teal
    static let appBlue           = Color(hex: "#1E6FDB") // accent blue

    // Text
    static let appTextPrimary    = Color(hex: "#E8EFF7")
    static let appTextSecondary  = Color(hex: "#7A9BB5")
    static let appTextMuted      = Color(hex: "#3D5A73")

    // State colours
    static let holdColour        = Color(hex: "#1E6FDB") // blue during hold
    static let restColour        = Color(hex: "#0ECDCD") // teal during rest
    static let warningColour     = Color(hex: "#F5A623") // orange warning
}

// MARK: - Hex initialiser
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
extension Font {
    static let appTitle      = Font.system(size: 28, weight: .bold,   design: .rounded)
    static let appHeadline   = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let appSubheadline = Font.system(size: 15, weight: .medium, design: .rounded)
    static let appBody       = Font.system(size: 14, weight: .regular, design: .rounded)
    static let appCaption    = Font.system(size: 12, weight: .regular, design: .rounded)
    static let timerLarge    = Font.system(size: 72, weight: .thin,    design: .monospaced)
    static let timerMedium   = Font.system(size: 48, weight: .thin,    design: .monospaced)
}

// MARK: - Spacing
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
}

// MARK: - Bundle helpers
extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

