import SwiftUI

extension Theme {
  enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
  }

  enum Radius {
    static let input: CGFloat = 14
    static let inputLarge: CGFloat = 16
    static let button: CGFloat = 15
    static let buttonLarge: CGFloat = 16
    static let fab: CGFloat = 18
    static let card: CGFloat = 18
    static let cardLarge: CGFloat = 24
    static let certificate: CGFloat = 26
    static let sheet: CGFloat = 30
    static let pill: CGFloat = 999
  }

  enum Size {
    static let primaryButtonHeight: CGFloat = 54
    static let primaryButtonHeightLarge: CGFloat = 56
    static let secondaryButtonHeight: CGFloat = 54
    static let googleSignInButtonHeight: CGFloat = 58
    static let inputHeight: CGFloat = 50
    static let tabBarHeight: CGFloat = 92
    static let fabSize: CGFloat = 54
    static let fabLift: CGFloat = -20
    static let verifiedDot: CGFloat = 8
    static let manualRingSize: CGFloat = 8
    static let statusBarHeight: CGFloat = 54

    // Score dial reference sizes (Phase 2 implements geometry)
    static let dialScoreTab: CGFloat = 272
    static let dialScoreHeader: CGFloat = 200
    static let dialHomeProgress: CGFloat = 156
    static let dialHomeCard: CGFloat = 130
    static let dialCompact: CGFloat = 82
  }

  enum Shadow {
    static let primaryButton = ShadowStyle(
      color: Theme.Colors.clay.opacity(0.30),
      radius: 18,
      x: 0,
      y: 8
    )

    static let card = ShadowStyle(
      color: Theme.Colors.espresso.opacity(0.05),
      radius: 24,
      x: 0,
      y: 8
    )

    static let fab = ShadowStyle(
      color: Theme.Colors.clay.opacity(0.42),
      radius: 22,
      x: 0,
      y: 10
    )

    static let googleButton = ShadowStyle(
      color: Theme.Colors.espresso.opacity(0.08),
      radius: 12,
      x: 0,
      y: 4
    )

    /// Soft upward shadow — separates tab bar from scroll content without a heavy chrome look.
    static let tabBar = ShadowStyle(
      color: Theme.Colors.espresso.opacity(0.07),
      radius: 10,
      x: 0,
      y: -3
    )
  }

  struct ShadowStyle: Sendable {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
  }
}

extension View {
  func themeShadow(_ style: Theme.ShadowStyle) -> some View {
    shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}
