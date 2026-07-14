import SwiftUI
import UIKit

extension Theme {
  enum Typography {
    private static let bricolageFamily = "Bricolage Grotesque"
    private static let hankenFamily = "Hanken Grotesk"
    private static let instrumentSerifPostScript = "InstrumentSerif-Italic"

    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
      customOrRounded(family: bricolageFamily, size: size, weight: weight)
    }

    static func score(_ size: CGFloat) -> Font {
      customOrRounded(family: bricolageFamily, size: size, weight: .heavy)
    }

    static func amount(_ size: CGFloat = 60) -> Font {
      customOrRounded(family: bricolageFamily, size: size, weight: .heavy)
    }

    static func wordmark(_ size: CGFloat = 28) -> Font {
      customOrRounded(family: bricolageFamily, size: size, weight: .bold)
    }

    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
      customOrText(family: hankenFamily, size: size, weight: weight)
    }

    static func body(_ size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
      customOrText(family: hankenFamily, size: size, weight: weight)
    }

    static func label(_ size: CGFloat = 13, weight: Font.Weight = .semibold) -> Font {
      customOrText(family: hankenFamily, size: size, weight: weight)
    }

    static func micro(_ size: CGFloat = 11, weight: Font.Weight = .semibold) -> Font {
      customOrText(family: hankenFamily, size: size, weight: weight)
    }

    static func accentItalic(_ size: CGFloat = 42) -> Font {
      if UIFont(name: instrumentSerifPostScript, size: size) != nil {
        return .custom(instrumentSerifPostScript, size: size)
      }
      return .system(size: size, weight: .regular, design: .serif).italic()
    }

    static let heroDisplay = display(38, weight: .bold)
    static let titleLarge = display(28, weight: .bold)
    static let titleMedium = display(24, weight: .bold)
    static let sectionHeader = ui(19, weight: .semibold)
    static let bodyRegular = body(15)
    static let bodySmall = body(14)
    static let buttonLabel = ui(16, weight: .bold)
    static let badgeLabel = label(13, weight: .bold)
    static let tierLabel = label(13, weight: .bold)

    static let tightTracking: CGFloat = -0.03
    static let displayTracking: CGFloat = -0.02
    static let uppercaseTracking: CGFloat = 0.14
    static let microTracking: CGFloat = 0.08

    private static func customOrRounded(family: String, size: CGFloat, weight: Font.Weight) -> Font {
      if UIFont(name: family, size: size) != nil || bundledFontAvailable(family) {
        return .custom(family, size: size).weight(weight)
      }
      return .system(size: size, weight: weight, design: .rounded)
    }

    private static func customOrText(family: String, size: CGFloat, weight: Font.Weight) -> Font {
      if UIFont(name: family, size: size) != nil || bundledFontAvailable(family) {
        return .custom(family, size: size).weight(weight)
      }
      return .system(size: size, weight: weight, design: .default)
    }

    private static func bundledFontAvailable(_ family: String) -> Bool {
      UIFont.familyNames.contains {
        $0.caseInsensitiveCompare(family) == .orderedSame
      }
    }
  }
}
