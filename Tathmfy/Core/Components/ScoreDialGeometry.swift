import Foundation

/// Pure geometry for the 220° score dial (README §4). Testable without SwiftUI.
enum ScoreDialGeometry: Sendable {
  static let arcStartDegreesFromTop: Double = 160
  static let arcSweepDegrees: Double = 220
  static let minScore = 300
  static let maxScore = 850
  static let scoreRange = maxScore - minScore
  static let strokeWidthRatio = 0.075
  static let knobRadiusRatio = 0.6

  /// Converts README top-clockwise degrees to SwiftUI `addArc` degrees (0° = east, clockwise).
  static func degreesFromEast(readmeDegreesFromTop: Double) -> Double {
    (270 + readmeDegreesFromTop).truncatingRemainder(dividingBy: 360)
  }

  static var trackStartDegrees: Double {
    degreesFromEast(readmeDegreesFromTop: arcStartDegreesFromTop)
  }

  static var trackEndDegrees: Double {
    trackStartDegrees + arcSweepDegrees
  }

  static func scoreFraction(_ score: Int) -> Double {
    let clamped = min(max(score, minScore), maxScore)
    return Double(clamped - minScore) / Double(scoreRange)
  }

  static func progressFraction(currentDay: Int, totalDays: Int) -> Double {
    guard totalDays > 0 else { return 0 }
    return min(max(Double(currentDay) / Double(totalDays), 0), 1)
  }

  static func valueEndDegrees(fraction: Double) -> Double {
    trackStartDegrees + arcSweepDegrees * min(max(fraction, 0), 1)
  }

  static func valueEndDegrees(score: Int) -> Double {
    valueEndDegrees(fraction: scoreFraction(score))
  }

  static func valueEndDegrees(currentDay: Int, totalDays: Int) -> Double {
    valueEndDegrees(fraction: progressFraction(currentDay: currentDay, totalDays: totalDays))
  }

  static func strokeWidth(diameter: CGFloat) -> CGFloat {
    diameter * strokeWidthRatio
  }

  static func knobDiameter(strokeWidth: CGFloat) -> CGFloat {
    strokeWidth * knobRadiusRatio * 2
  }

  /// Point on the dial arc for knob placement (SwiftUI coordinates, y-down).
  static func pointOnArc(
    center: CGPoint,
    radius: CGFloat,
    degreesFromEast: Double
  ) -> CGPoint {
    let radians = degreesFromEast * .pi / 180
    return CGPoint(
      x: center.x + radius * cos(radians),
      y: center.y + radius * sin(radians)
    )
  }

  static func scoreFontSize(diameter: CGFloat) -> CGFloat {
    diameter * 0.26
  }

  static func tierFontSize(diameter: CGFloat) -> CGFloat {
    max(diameter * 0.075, 10)
  }

  static func progressSubLabelFontSize(diameter: CGFloat) -> CGFloat {
    max(diameter * 0.07, 10)
  }
}

enum ScoreDialMode: Equatable, Sendable {
  case score(Int)
  case progress(currentDay: Int, totalDays: Int = 30)
}

extension ScoreDialMode {
  var targetFraction: Double {
    switch self {
    case let .score(value):
      ScoreDialGeometry.scoreFraction(value)
    case let .progress(currentDay, totalDays):
      ScoreDialGeometry.progressFraction(currentDay: currentDay, totalDays: totalDays)
    }
  }
}
