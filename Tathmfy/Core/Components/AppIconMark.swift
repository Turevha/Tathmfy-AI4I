import SwiftUI

/// App icon mark — brand arc on radial espresso ground (README §3.1, design `iconMarkSm`).
struct AppIconMark: View {
  var size: CGFloat = 84
  var cornerRadius: CGFloat = 23

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(
          RadialGradient(
            colors: [Color(hex: 0x33251C), Color(hex: 0x221911)],
            center: UnitPoint(x: 0.3, y: 0.2),
            startRadius: 0,
            endRadius: size * 0.85
          )
        )

      BrandLogoMark(diameter: size * 0.60, dotColor: Color(hex: 0xF3ECE0))
    }
    .frame(width: size, height: size)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    .themeShadow(
      Theme.ShadowStyle(
        color: Color(hex: 0x221911).opacity(0.28),
        radius: 26,
        x: 0,
        y: 12
      )
    )
  }
}

#Preview {
  AppIconMark()
    .padding()
    .background(Theme.Colors.bone)
}
