import SwiftUI

struct OnboardingView: View {
  let onGetStarted: () -> Void

  var body: some View {
    GeometryReader { geo in
      let layout = OnboardingLayout(size: geo.size, safeArea: geo.safeAreaInsets)

      ZStack {
        Theme.Colors.onboardingGradient
          .ignoresSafeArea()

        // Hero arc — design: left:-90, top:120, 520×520, opacity:.5, no mid-band clip.
        BrandLogoMark(diameter: layout.arcDiameter, dotColor: Theme.Colors.goldAmber)
          .opacity(0.5)
          .position(x: layout.arcCenterX, y: layout.arcCenterY)
          .allowsHitTesting(false)

        VStack(spacing: 0) {
          Text("Tathmfy")
            .font(Theme.Typography.wordmark(18))
            .foregroundStyle(Theme.Colors.bone)
            .tracking(Theme.Typography.tightTracking)
            .frame(maxWidth: .infinity)
            .padding(.top, layout.wordmarkTop)

          Spacer(minLength: layout.contentTopInset)

          contentBlock
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.bottom, layout.bottomPadding)
        }
        .frame(width: geo.size.width, height: geo.size.height)
      }
    }
  }

  private var contentBlock: some View {
    VStack(alignment: .leading, spacing: 0) {
      africaPill

      Text("Your money has\na story.")
        .font(Theme.Typography.heroDisplay)
        .foregroundStyle(Color(hex: 0xF7F1E7))
        .tracking(Theme.Typography.tightTracking)
        .lineSpacing(1)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)

      Text("Finally, someone's listening.")
        .font(Theme.Typography.accentItalic(42))
        .foregroundStyle(Theme.Colors.goldAmber)
        .lineSpacing(2)
        .lineLimit(2)
        .minimumScaleFactor(0.82)
        .padding(.top, 4)
        .fixedSize(horizontal: false, vertical: true)

      Text(
        "Millions live full financial lives the credit system never sees. Tathmfy turns what you already do — earning, spending, saving — into a score that's truly yours."
      )
      .font(Theme.Typography.body(15, weight: .medium))
      .foregroundStyle(Theme.Colors.onboardingSubtext)
      .lineSpacing(5)
      .frame(maxWidth: 300, alignment: .leading)
      .padding(.top, 18)
      .fixedSize(horizontal: false, vertical: true)

      Button(action: onGetStarted) {
        Text("Get started")
          .font(Theme.Typography.ui(17, weight: .bold))
          .foregroundStyle(Theme.Colors.espresso)
          .frame(maxWidth: .infinity)
          .frame(height: Theme.Size.primaryButtonHeightLarge)
          .background(Theme.Colors.bone)
          .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.buttonLarge, style: .continuous))
      }
      .buttonStyle(.plain)
      .padding(.top, 26)

      HStack(spacing: 8) {
        Image(systemName: "lock.fill")
          .font(.system(size: 12, weight: .medium))
        Text("Private by design · your data stays on your phone")
          .font(Theme.Typography.ui(12, weight: .medium))
      }
      .foregroundStyle(Color(hex: 0xA98F77))
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.top, 18)
    }
  }

  private var africaPill: some View {
    HStack(spacing: 7) {
      Circle()
        .fill(Theme.Colors.gold)
        .frame(width: 7, height: 7)
      Text("Built for all of Africa")
        .font(Theme.Typography.label(12, weight: .semibold))
        .foregroundStyle(Color(hex: 0xE7D9C7))
        .tracking(0.04)
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 7)
    .background(Color.white.opacity(0.10))
    .overlay {
      Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
    }
    .clipShape(Capsule())
    .padding(.bottom, 22)
  }
}

/// Layout tokens from design handoff §5.1 (393×852 baseline).
private struct OnboardingLayout {
  let arcDiameter: CGFloat
  let arcCenterX: CGFloat
  let arcCenterY: CGFloat
  let horizontalPadding: CGFloat
  let bottomPadding: CGFloat
  let wordmarkTop: CGFloat
  let contentTopInset: CGFloat

  init(size: CGSize, safeArea: EdgeInsets) {
    let widthScale = size.width / Theme.Layout.designWidth
    let heightScale = size.height / 852

    arcDiameter = 520 * widthScale
    let arcOffsetX = -90 * widthScale
    let arcOffsetY = 120 * heightScale
    arcCenterX = arcDiameter / 2 + arcOffsetX
    arcCenterY = arcDiameter / 2 + arcOffsetY

    horizontalPadding = 32 * widthScale
    bottomPadding = max(38 * heightScale, safeArea.bottom + 12)
    wordmarkTop = safeArea.top + 24 * heightScale

    // Keep copy below the visible arc sweep (~48% of screen on baseline).
    contentTopInset = size.height * 0.465
  }
}

#Preview("iPhone 15 Pro") {
  OnboardingView(onGetStarted: {})
}

#Preview("iPhone 15 Pro Max") {
  OnboardingView(onGetStarted: {})
    .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
}
