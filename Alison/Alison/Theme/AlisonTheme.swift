import SwiftUI

enum AlisonTheme {
    static let ink = Color(red: 0.06, green: 0.06, blue: 0.07)
    static let mist = Color(red: 0.92, green: 0.90, blue: 0.86)
    static let champagne = Color(red: 0.78, green: 0.66, blue: 0.45)
    static let steel = Color(red: 0.55, green: 0.56, blue: 0.58)
    static let soft = Color(red: 0.14, green: 0.14, blue: 0.15)

    static let display = Font.custom("Didot", size: 42)
    static let displaySmall = Font.custom("Didot", size: 28)
    static let body = Font.system(size: 15, weight: .regular, design: .serif)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
}
