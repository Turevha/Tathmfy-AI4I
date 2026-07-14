import SwiftUI

struct GoogleSignInButton: View {
  var isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        if isLoading {
          ProgressView()
            .tint(Theme.Colors.espresso)
        } else {
          GoogleLogoGlyph()
            .frame(width: 22, height: 22)
        }
        Text("Continue with Google")
          .font(Theme.Typography.ui(16, weight: .bold))
          .foregroundStyle(Theme.Colors.espresso)
      }
      .frame(maxWidth: .infinity)
      .frame(height: Theme.Size.googleSignInButtonHeight)
      .background(Theme.Colors.boneCard)
      .overlay {
        RoundedRectangle(cornerRadius: Theme.Radius.buttonLarge, style: .continuous)
          .strokeBorder(Theme.Colors.secondaryBorder, lineWidth: 1)
      }
      .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.buttonLarge, style: .continuous))
      .themeShadow(Theme.Shadow.googleButton)
    }
    .buttonStyle(.plain)
    .disabled(isLoading)
  }
}

/// Multicolor Google "G" from the design handoff SVG.
struct GoogleLogoGlyph: View {
  var body: some View {
    ZStack {
      GooglePathShape(
        d: "M24 9.5c3.5 0 6.6 1.2 9 3.6l6.7-6.7C35.6 2.6 30.1 0 24 0 14.6 0 6.4 5.4 2.5 13.3l7.8 6c1.9-5.6 7.1-9.8 13.7-9.8z"
      )
      .fill(Color(hex: 0xEA4335))
      GooglePathShape(
        d: "M46.5 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.7c-.5 3-2.2 5.5-4.7 7.2l7.3 5.7c4.3-3.9 6.7-9.7 6.7-17.4z"
      )
      .fill(Color(hex: 0x4285F4))
      GooglePathShape(
        d: "M10.3 19.3a14.4 14.4 0 0 0 0 9.4l-7.8 6A24 24 0 0 1 0 24c0-3.9.9-7.5 2.5-10.7l7.8 6z"
      )
      .fill(Color(hex: 0xFBBC05))
      GooglePathShape(
        d: "M24 48c6.1 0 11.3-2 15-5.5l-7.3-5.7c-2 1.4-4.7 2.3-7.7 2.3-6.6 0-11.8-4.2-13.7-9.8l-7.8 6C6.4 42.6 14.6 48 24 48z"
      )
      .fill(Color(hex: 0x34A853))
    }
    .frame(width: 22, height: 22)
  }
}

private struct GooglePathShape: Shape {
  let d: String

  func path(in rect: CGRect) -> Path {
    guard let cgPath = GoogleSVGPathParser.path(from: d) else {
      return Path()
    }
    let scale = min(rect.width / 48, rect.height / 48)
    var transform = CGAffineTransform(scaleX: scale, y: scale)
    guard let scaled = cgPath.copy(using: &transform) else {
      return Path(cgPath)
    }
    return Path(scaled)
  }
}

private enum GoogleSVGPathParser {
  static func path(from d: String) -> CGPath? {
    let p = CGMutablePath()
    var current = CGPoint.zero
    var start = CGPoint.zero
    let tokens = tokenize(d)
    var i = 0

    while i < tokens.count {
      let cmd = tokens[i]
      i += 1

      switch cmd {
      case "M":
        guard i + 1 < tokens.count,
              let x = Double(tokens[i]), let y = Double(tokens[i + 1]) else { return nil }
        i += 2
        current = CGPoint(x: x, y: y)
        start = current
        p.move(to: current)
      case "L":
        guard i + 1 < tokens.count,
              let x = Double(tokens[i]), let y = Double(tokens[i + 1]) else { return nil }
        i += 2
        current = CGPoint(x: x, y: y)
        p.addLine(to: current)
      case "H":
        guard let x = Double(tokens[i]) else { return nil }
        i += 1
        current = CGPoint(x: x, y: current.y)
        p.addLine(to: current)
      case "V":
        guard let y = Double(tokens[i]) else { return nil }
        i += 1
        current = CGPoint(x: current.x, y: y)
        p.addLine(to: current)
      case "C":
        guard i + 5 < tokens.count,
              let x1 = Double(tokens[i]), let y1 = Double(tokens[i + 1]),
              let x2 = Double(tokens[i + 2]), let y2 = Double(tokens[i + 3]),
              let x = Double(tokens[i + 4]), let y = Double(tokens[i + 5]) else { return nil }
        i += 6
        p.addCurve(
          to: CGPoint(x: x, y: y),
          control1: CGPoint(x: x1, y: y1),
          control2: CGPoint(x: x2, y: y2)
        )
        current = CGPoint(x: x, y: y)
      case "c":
        guard i + 5 < tokens.count,
              let dx1 = Double(tokens[i]), let dy1 = Double(tokens[i + 1]),
              let dx2 = Double(tokens[i + 2]), let dy2 = Double(tokens[i + 3]),
              let dx = Double(tokens[i + 4]), let dy = Double(tokens[i + 5]) else { return nil }
        i += 6
        let c1 = CGPoint(x: current.x + dx1, y: current.y + dy1)
        let c2 = CGPoint(x: current.x + dx2, y: current.y + dy2)
        current = CGPoint(x: current.x + dx, y: current.y + dy)
        p.addCurve(to: current, control1: c1, control2: c2)
      case "l":
        guard i + 1 < tokens.count,
              let dx = Double(tokens[i]), let dy = Double(tokens[i + 1]) else { return nil }
        i += 2
        current = CGPoint(x: current.x + dx, y: current.y + dy)
        p.addLine(to: current)
      case "Z", "z":
        p.closeSubpath()
        current = start
      default:
        continue
      }
    }

    return p
  }

  private static func tokenize(_ d: String) -> [String] {
    var result: [String] = []
    var current = ""
    for char in d {
      if char.isLetter {
        if !current.isEmpty { result.append(current); current = "" }
        result.append(String(char))
      } else if char == "," || char == " " {
        if !current.isEmpty { result.append(current); current = "" }
      } else if char == "-" && !current.isEmpty {
        result.append(current)
        current = String(char)
      } else {
        current.append(char)
      }
    }
    if !current.isEmpty { result.append(current) }
    return result
  }
}

struct SignInView: View {
  let isSigningIn: Bool
  let errorMessage: String?
  let onSignIn: () -> Void
  let onDemoSignIn: () -> Void

  var body: some View {
    GeometryReader { geo in
      let layout = SignInLayout(size: geo.size, safeArea: geo.safeAreaInsets)

      ZStack {
        Theme.Colors.bone.ignoresSafeArea()

        BrandLogoMark(diameter: layout.watermarkSize, dotColor: Theme.Colors.goldAmber.opacity(0.5))
          .opacity(0.07)
          .offset(y: layout.watermarkOffsetY)
          .allowsHitTesting(false)

        VStack(spacing: 0) {
          heroSection
            .padding(.top, layout.heroTop)
            .padding(.horizontal, layout.horizontalPadding)

          Spacer(minLength: 20)

          trustHighlights
            .padding(.horizontal, layout.horizontalPadding)

          Spacer(minLength: 20)

          signInFooter
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.bottom, layout.footerBottom)
        }
        .frame(width: geo.size.width, height: geo.size.height)
      }
    }
  }

  private var heroSection: some View {
    VStack(spacing: 30) {
      AppIconMark(size: 84, cornerRadius: 23)

      VStack(spacing: 10) {
        Text("Welcome to Tathmfy")
          .font(Theme.Typography.titleLarge)
          .foregroundStyle(Theme.Colors.espresso)
          .tracking(Theme.Typography.displayTracking)
          .multilineTextAlignment(.center)

        Text("One step. We use your Google account to keep your identity secure — nothing else.")
          .font(Theme.Typography.body(15, weight: .medium))
          .foregroundStyle(Theme.Colors.taupeDark)
          .multilineTextAlignment(.center)
          .lineSpacing(3)
          .frame(maxWidth: 280)
      }
    }
    .frame(maxWidth: .infinity)
  }

  private var trustHighlights: some View {
    VStack(spacing: 12) {
      HStack(spacing: 10) {
        trustChip(icon: "lock.fill", label: "Private by design")
        trustChip(icon: "iphone", label: "On-device only")
      }
      HStack(spacing: 10) {
        trustChip(icon: "checkmark.shield.fill", label: "Verified scans")
        trustChip(icon: "person.fill.checkmark", label: "Score you own")
      }
    }
  }

  private func trustChip(icon: String, label: String) -> some View {
    HStack(spacing: 7) {
      Image(systemName: icon)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(Theme.Colors.jewelTeal)
      Text(label)
        .font(Theme.Typography.ui(12, weight: .semibold))
        .foregroundStyle(Theme.Colors.taupeDark)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity)
    .background(Theme.Colors.boneCard)
    .overlay {
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .strokeBorder(Theme.Colors.sandLine, lineWidth: 1)
    }
    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
  }

  private var signInFooter: some View {
    VStack(spacing: Theme.Spacing.md) {
      GoogleSignInButton(isLoading: isSigningIn, action: onSignIn)

      #if DEBUG
      Button("Continue with demo account") {
        onDemoSignIn()
      }
      .font(Theme.Typography.label(14, weight: .semibold))
      .foregroundStyle(Theme.Colors.jewelTeal)
      #endif

      if let errorMessage {
        Text(errorMessage)
          .font(Theme.Typography.bodySmall)
          .foregroundStyle(Theme.Colors.clay)
          .multilineTextAlignment(.center)
      }

      Text("By continuing you agree to our Terms & Privacy.\nYour financial data never leaves this device.")
        .font(Theme.Typography.ui(12, weight: .medium))
        .foregroundStyle(Theme.Colors.taupe)
        .multilineTextAlignment(.center)
        .lineSpacing(4)
    }
  }
}

private struct SignInLayout {
  let horizontalPadding: CGFloat
  let heroTop: CGFloat
  let footerBottom: CGFloat
  let watermarkSize: CGFloat
  let watermarkOffsetY: CGFloat

  init(size: CGSize, safeArea: EdgeInsets) {
    let widthScale = size.width / Theme.Layout.designWidth
    let heightScale = size.height / 852

    horizontalPadding = 32 * widthScale
    heroTop = safeArea.top + 96 * heightScale
    footerBottom = max(44 * heightScale, safeArea.bottom + 12)
    watermarkSize = 280 * widthScale
    watermarkOffsetY = 40 * heightScale
  }
}

#Preview {
  SignInView(isSigningIn: false, errorMessage: nil, onSignIn: {}, onDemoSignIn: {})
}
