import SwiftUI

extension Theme {
  enum Colors {
    // MARK: - Brand

    static let clay = Color(hex: 0xC8553A)
    static let claySoft = Color(hex: 0xE2A593)

    // MARK: - Ink & surfaces

    static let espresso = Color(hex: 0x271C16)
    static let espressoGradStart = Color(hex: 0x32241B)
    static let espressoGradEnd = Color(hex: 0x231A13)

    static let bone = Color(hex: 0xF3ECE0)
    static let boneCard = Color(hex: 0xFFFFFF)

    // MARK: - Verified / teal

    static let jewelTeal = Color(hex: 0x1C6E60)
    static let tealBright = Color(hex: 0x54B79F)
    static let tealWash = Color(hex: 0xE4EFEA)

    // MARK: - Score / gold

    static let gold = Color(hex: 0xD99A33)
    static let goldAmber = Color(hex: 0xE9A65C)
    static let goldMid = Color(hex: 0xC9A23A)
    static let excellentTeal = Color(hex: 0x155446)

    // MARK: - Neutrals

    static let sandLine = Color(hex: 0xECE3D5)
    static let sandLineAlt = Color(hex: 0xE7DDCE)
    static let sandInput = Color(hex: 0xF6F1E8)
    static let taupe = Color(hex: 0x9A8C7E)
    static let taupeDark = Color(hex: 0x6B5D52)
    static let track = Color(hex: 0xEBE2D3)
    static let trackAlt = Color(hex: 0xEFE7D8)

    // MARK: - Component-specific

    static let secondaryBorder = Color(hex: 0xE2D7C6)
    static let manualBadgeBackground = Color(hex: 0xF1EADD)
    static let manualBadgeRing = Color(hex: 0xB6A691)
    static let activatingBackground = Color(hex: 0xF6E9D3)
    static let indicativeChipBackground = Color(hex: 0xF6E4DC)
    static let onboardingSubtext = Color(hex: 0xD8C8B5)
    static let amountCentsMuted = Color(hex: 0xC7B8A6)
    static let avatarBackground = Color(hex: 0xE6BC57)

    // MARK: - Tab bar

    /// Design: `#FAF6EE` — lifted surface above bone content (`#F3ECE0`).
    static let tabBarSurface = Color(hex: 0xFAF6EE)
    /// Slightly stronger than `sandLineAlt` so the bar reads on bone backgrounds.
    static let tabBarBorder = Color(hex: 0xD9CFC0)
    static let tabBarBackground = tabBarSurface

    // MARK: - Onboarding gradient stops

    static let onboardingGradTop = Color(hex: 0x2B1F18)
    static let onboardingGradMid = Color(hex: 0x3A2418)
    static let onboardingGradBottom = Color(hex: 0x5A2D1C)

    // MARK: - Gradients

    static var espressoGradient: LinearGradient {
      LinearGradient(
        colors: [espressoGradStart, espressoGradEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }

    static var onboardingGradient: LinearGradient {
      LinearGradient(
        stops: [
          .init(color: onboardingGradTop, location: 0),
          .init(color: onboardingGradMid, location: 0.52),
          .init(color: onboardingGradBottom, location: 1),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
      )
    }

    static var scoreDialValueGradient: [Gradient.Stop] {
      [
        .init(color: clay, location: 0),
        .init(color: gold, location: 0.42),
        .init(color: goldMid, location: 0.72),
        .init(color: jewelTeal, location: 1),
      ]
    }
  }
}

extension Color {
  init(hex: UInt32, opacity: Double = 1) {
    let red = Double((hex >> 16) & 0xFF) / 255
    let green = Double((hex >> 8) & 0xFF) / 255
    let blue = Double(hex & 0xFF) / 255
    self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}
