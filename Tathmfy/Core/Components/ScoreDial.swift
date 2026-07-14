import SwiftUI

private struct DialArcShape: Shape {
  var startDegrees: Double
  var endDegrees: Double
  var strokeWidth: CGFloat

  var animatableData: Double {
    get { endDegrees }
    set { endDegrees = newValue }
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = (min(rect.width, rect.height) - strokeWidth) / 2

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

enum ScoreDialAppearance {
  case light
  case dark
}

struct ScoreDial: View {
  var diameter: CGFloat
  var mode: ScoreDialMode
  var appearance: ScoreDialAppearance = .light
  /// When false, the dial renders at its target value with no sweep.
  var animate: Bool = true

  @State private var animatedEndDegrees = ScoreDialGeometry.trackStartDegrees
  @State private var animatedScore = Double(ScoreDialGeometry.minScore)

  private var strokeWidth: CGFloat {
    ScoreDialGeometry.strokeWidth(diameter: diameter)
  }

  private var arcRadius: CGFloat {
    (diameter - strokeWidth) / 2
  }

  private var targetEndDegrees: Double {
    ScoreDialGeometry.valueEndDegrees(fraction: mode.targetFraction)
  }

  private var targetScore: Double {
    switch mode {
    case let .score(value):
      Double(value)
    case let .progress(currentDay, _):
      Double(currentDay)
    }
  }

  private var animationIdentity: String {
    switch mode {
    case let .score(value):
      "score-\(value)"
    case let .progress(currentDay, totalDays):
      "progress-\(currentDay)-\(totalDays)"
    }
  }

  var body: some View {
    ZStack {
      trackArc
      valueArc
      knob
      centerContent
    }
    .frame(width: diameter, height: diameter)
    .task(id: animationIdentity) {
      await runSweepAnimation()
    }
  }

  private var trackArc: some View {
    DialArcShape(
      startDegrees: ScoreDialGeometry.trackStartDegrees,
      endDegrees: ScoreDialGeometry.trackEndDegrees,
      strokeWidth: strokeWidth
    )
    .stroke(
      Theme.Colors.sandLineAlt,
      style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
    )
  }

  @ViewBuilder
  private var valueArc: some View {
    switch mode {
    case .score:
      DialArcShape(
        startDegrees: ScoreDialGeometry.trackStartDegrees,
        endDegrees: animatedEndDegrees,
        strokeWidth: strokeWidth
      )
      .stroke(
        AngularGradient(
          gradient: Gradient(stops: Theme.Colors.scoreDialValueGradient),
          center: .center,
          startAngle: .degrees(ScoreDialGeometry.trackStartDegrees),
          endAngle: .degrees(ScoreDialGeometry.trackEndDegrees)
        ),
        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
      )

    case .progress:
      DialArcShape(
        startDegrees: ScoreDialGeometry.trackStartDegrees,
        endDegrees: animatedEndDegrees,
        strokeWidth: strokeWidth
      )
      .stroke(
        Theme.Colors.gold,
        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
      )
    }
  }

  private var knob: some View {
    let knobSize = ScoreDialGeometry.knobDiameter(strokeWidth: strokeWidth)

    return ZStack {
      Circle()
        .fill(Color.white)
        .frame(width: knobSize, height: knobSize)
        .overlay {
          Circle()
            .strokeBorder(Theme.Colors.jewelTeal, lineWidth: max(strokeWidth * 0.18, 1.5))
        }
        .offset(x: arcRadius)
    }
    .rotationEffect(.degrees(animatedEndDegrees))
  }

  @ViewBuilder
  private var centerContent: some View {
    switch mode {
    case .score:
      let displayScore = Int(animatedScore.rounded())
      let tier = ScoreTier.tier(for: displayScore)
      let scoreColor = appearance == .dark ? Color(hex: 0xF7F1E7) : Theme.Colors.espresso
      let tierColor = appearance == .dark ? Theme.Colors.tealBright : tier.color
      VStack(spacing: diameter * 0.02) {
        Text("\(displayScore)")
          .font(Theme.Typography.score(ScoreDialGeometry.scoreFontSize(diameter: diameter)))
          .foregroundStyle(scoreColor)
          .tracking(Theme.Typography.tightTracking)
          .minimumScaleFactor(0.6)
          .lineLimit(1)
          .monospacedDigit()
          .contentTransition(.numericText())

        Text(tier.displayName.uppercased())
          .font(Theme.Typography.label(ScoreDialGeometry.tierFontSize(diameter: diameter), weight: .bold))
          .foregroundStyle(tierColor)
          .tracking(Theme.Typography.uppercaseTracking)
      }
      .padding(.horizontal, strokeWidth * 2)

    case let .progress(_, totalDays):
      let displayDay = max(1, Int(animatedScore.rounded()))
      VStack(spacing: diameter * 0.015) {
        Text("\(displayDay)")
          .font(Theme.Typography.score(ScoreDialGeometry.scoreFontSize(diameter: diameter)))
          .foregroundStyle(Theme.Colors.espresso)
          .tracking(Theme.Typography.tightTracking)
          .monospacedDigit()
          .contentTransition(.numericText())

        Text("of \(totalDays) days")
          .font(Theme.Typography.ui(ScoreDialGeometry.progressSubLabelFontSize(diameter: diameter), weight: .semibold))
          .foregroundStyle(Theme.Colors.taupe)
          .tracking(Theme.Typography.microTracking)
          .textCase(.uppercase)
      }
    }
  }

  @MainActor
  private func runSweepAnimation() async {
    guard animate else {
      animatedEndDegrees = targetEndDegrees
      animatedScore = targetScore
      return
    }

    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction) {
      animatedEndDegrees = ScoreDialGeometry.trackStartDegrees
      animatedScore = switch mode {
      case .score:
        Double(ScoreDialGeometry.minScore)
      case .progress:
        0
      }
    }

    await Task.yield()

    withAnimation(.easeOut(duration: 0.9)) {
      animatedEndDegrees = targetEndDegrees
      animatedScore = targetScore
    }
  }
}

#Preview("Score — Good") {
  ScoreDial(diameter: Theme.Size.dialScoreHeader, mode: .score(712))
    .padding()
    .background(Theme.Colors.bone)
}

#Preview("Score — Building") {
  ScoreDial(diameter: Theme.Size.dialHomeCard, mode: .score(480))
    .padding()
    .background(Theme.Colors.bone)
}

#Preview("Progress — Day 1") {
  ScoreDial(diameter: Theme.Size.dialHomeProgress, mode: .progress(currentDay: 1))
    .padding()
    .background(Theme.Colors.boneCard)
}

#Preview("Score — Tab size") {
  ScoreDial(diameter: Theme.Size.dialScoreTab, mode: .score(712))
    .padding()
    .background(Theme.Colors.bone)
}

#Preview("Score — Share card dark") {
  ScoreDial(diameter: 140, mode: .score(712), appearance: .dark)
    .padding()
    .background(Color(hex: 0x2E2017))
}
