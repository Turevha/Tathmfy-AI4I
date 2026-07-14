import SwiftUI

/// Canonical Tathmfy logo mark — full 220° gradient arc + terminal dot (design `logo()`).
struct BrandLogoMark: View {
  var diameter: CGFloat
  var dotColor: Color = Color(hex: 0xF3ECE0)
  /// Design `logo()` uses 13.5% stroke; score dials use 7.5%.
  var strokeRatio: CGFloat = 0.135

  private var strokeWidth: CGFloat {
    diameter * strokeRatio
  }

  private var arcRadius: CGFloat {
    diameter / 2 - strokeWidth / 2 - 1
  }

  private var sweepEndDegrees: Double {
    ScoreDialGeometry.trackEndDegrees
  }

  var body: some View {
    ZStack {
      BrandArcShape(
        startDegrees: ScoreDialGeometry.trackStartDegrees,
        endDegrees: sweepEndDegrees,
        strokeWidth: strokeWidth
      )
      .stroke(
        AngularGradient(
          gradient: Gradient(stops: [
            .init(color: Color(hex: 0xD9663F), location: 0),
            .init(color: Color(hex: 0xE5A93E), location: 0.5),
            .init(color: Color(hex: 0x2E8676), location: 1),
          ]),
          center: .center,
          startAngle: .degrees(ScoreDialGeometry.trackStartDegrees),
          endAngle: .degrees(ScoreDialGeometry.trackEndDegrees)
        ),
        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
      )

      Circle()
        .fill(dotColor)
        .frame(width: knobDiameter, height: knobDiameter)
        .offset(x: arcRadius)
        .rotationEffect(.degrees(sweepEndDegrees))
    }
    .frame(width: diameter, height: diameter)
  }

  private var knobDiameter: CGFloat {
    strokeWidth * 0.72 * 2
  }
}

struct BrandArcShape: Shape {
  var startDegrees: Double
  var endDegrees: Double
  var strokeWidth: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = min(rect.width, rect.height) / 2 - strokeWidth / 2 - 1

    path.addArc(
      center: center,
      radius: radius,
      startAngle: .degrees(startDegrees),
      endAngle: .degrees(endDegrees),
      clockwise: false
    )

    return path
  }
}

#Preview("Icon size") {
  BrandLogoMark(diameter: 50, dotColor: Color(hex: 0xF3ECE0))
    .padding()
    .background(Color(hex: 0x221911))
}

#Preview("Hero size") {
  BrandLogoMark(diameter: 520, dotColor: Theme.Colors.goldAmber)
    .opacity(0.5)
    .padding()
    .background(Theme.Colors.onboardingGradTop)
}
