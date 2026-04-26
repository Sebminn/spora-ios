import SwiftUI

extension Font {
    enum Spora {
        static let brand   = custom("Fraunces", size: 32, weight: .semibold, fallback: .system(size: 32, weight: .semibold, design: .serif))
        static let title1  = custom("Onest",    size: 28, weight: .bold,     fallback: .system(size: 28, weight: .bold))
        static let title2  = custom("Onest",    size: 22, weight: .bold,     fallback: .system(size: 22, weight: .bold))
        static let title3  = custom("Onest",    size: 17, weight: .semibold, fallback: .system(size: 17, weight: .semibold))
        static let body    = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
    }

    private static func custom(_ name: String, size: CGFloat, weight: Font.Weight, fallback: Font) -> Font {
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size).weight(weight)
        }
        return fallback
    }
}
