import SwiftUI
import UIKit

extension Color {
    enum Spora {
        static let background = dynamic(light: 0xF5EFE4, dark: 0x1B1410)
        static let surface    = dynamic(light: 0xFBF7EF, dark: 0x26201A)
        static let primary    = dynamic(light: 0x6B4F3B, dark: 0xC9A88A)
        static let primaryOn  = dynamic(light: 0xFBF7EF, dark: 0x1B1410)
        static let accent     = dynamic(light: 0x5F7A5A, dark: 0x8FB089)
        static let secondary  = dynamic(light: 0xB5895A, dark: 0xD6B68C)
        static let warning    = dynamic(light: 0xB5634A, dark: 0xD17F65)
        static let textPrimary   = dynamic(light: 0x2B1F17, dark: 0xF2EAE0)
        static let textSecondary = dynamic(light: 0x6F5F52, dark: 0xB8A597)
        static let divider    = dynamic(light: 0xE6DCCC, dark: 0x3A2F26)
    }

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:  CGFloat( hex        & 0xFF) / 255,
            alpha: 1
        )
    }
}
