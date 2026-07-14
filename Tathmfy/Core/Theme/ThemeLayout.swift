import SwiftUI

extension Theme {
  /// Layout tokens for responsive screens (design baseline: iPhone 15 Pro / 393pt).
  enum Layout {
    static let designWidth: CGFloat = 393
    static let screenHorizontalPadding: CGFloat = 28
    static let onboardingHorizontalPadding: CGFloat = 32

    /// Modest scale factor for hero elements on Pro Max (caps at ~8%).
    static func contentScale(for screenWidth: CGFloat) -> CGFloat {
      min(1.08, max(1, screenWidth / designWidth))
    }

    /// Side inset used by tab screens — grows slightly on wider phones.
    static func horizontalInset(for screenWidth: CGFloat) -> CGFloat {
      max(screenHorizontalPadding, (screenWidth - designWidth) / 2 + 12)
    }

    static func chatBubbleMaxWidth(for screenWidth: CGFloat, isUser: Bool) -> CGFloat {
      screenWidth * (isUser ? 0.72 : 0.82)
    }
  }
}

private struct ScreenHorizontalPaddingModifier: ViewModifier {
  var useOnboardingPadding: Bool

  func body(content: Content) -> some View {
    GeometryReader { proxy in
      let inset = useOnboardingPadding
        ? Theme.Layout.onboardingHorizontalPadding
        : Theme.Layout.horizontalInset(for: proxy.size.width)

      content
        .padding(.horizontal, inset)
        .frame(width: proxy.size.width, alignment: .top)
    }
  }
}

extension View {
  func screenHorizontalPadding(onboarding: Bool = false) -> some View {
    modifier(ScreenHorizontalPaddingModifier(useOnboardingPadding: onboarding))
  }
}
