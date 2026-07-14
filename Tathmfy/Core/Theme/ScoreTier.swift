import SwiftUI

enum ScoreTier: String, CaseIterable, Sendable {
  case building
  case fair
  case good
  case strong
  case excellent

  var displayName: String {
    switch self {
    case .building: "Building"
    case .fair: "Fair"
    case .good: "Good"
    case .strong: "Strong"
    case .excellent: "Excellent"
    }
  }

  var color: Color {
    switch self {
    case .building: Theme.Colors.clay
    case .fair: Theme.Colors.gold
    case .good: Theme.Colors.goldMid
    case .strong: Theme.Colors.jewelTeal
    case .excellent: Theme.Colors.excellentTeal
    }
  }

  static func tier(for score: Int) -> ScoreTier {
    switch score {
    case ..<580: .building
    case 580..<670: .fair
    case 670..<740: .good
    case 740..<800: .strong
    default: .excellent
    }
  }
}
