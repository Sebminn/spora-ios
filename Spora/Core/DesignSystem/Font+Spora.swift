import SwiftUI

extension Font {
    enum Spora {
        static let brand   = custom("Fraunces", size: 28, weight: .semibold, fallback: .system(size: 28, weight: .semibold, design: .serif))
        static let title1  = custom("Onest",    size: 22, weight: .bold,     fallback: .system(size: 22, weight: .bold))
        static let title2  = custom("Onest",    size: 18, weight: .bold,     fallback: .system(size: 18, weight: .bold))
        static let title3  = custom("Onest",    size: 15, weight: .semibold, fallback: .system(size: 15, weight: .semibold))
        static let body    = Font.system(size: 15, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
    }

    private static func custom(_ name: String, size: CGFloat, weight: Font.Weight, fallback: Font) -> Font {
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size).weight(weight)
        }
        return fallback
    }
}
