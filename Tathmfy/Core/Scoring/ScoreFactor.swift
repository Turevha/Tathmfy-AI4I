import Foundation
import SwiftUI

enum ScoreFactor: String, CaseIterable, Sendable, Identifiable {
  case paymentConsistency
  case incomeStability
  case spendingDiscipline
  case dataDepth
  case dataVerification

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .paymentConsistency: "Payment consistency"
    case .incomeStability: "Income stability"
    case .spendingDiscipline: "Spending discipline"
    case .dataDepth: "Data depth"
    case .dataVerification: "Data verification"
    }
  }

  var weight: Double {
    switch self {
    case .paymentConsistency: 0.35
    case .incomeStability: 0.25
    case .spendingDiscipline: 0.20
    case .dataDepth: 0.15
    case .dataVerification: 0.05
    }
  }

  var color: Color {
    switch self {
    case .paymentConsistency: Theme.Colors.jewelTeal
    case .incomeStability: Color(hex: 0xE0922E)
    case .spendingDiscipline: Color(hex: 0x3E9583)
    case .dataDepth: Color(hex: 0xCDA24A)
    case .dataVerification: Theme.Colors.jewelTeal
    }
  }

  /// Days after joinDate before this factor activates.
  var activationDay: Int {
    switch self {
    case .paymentConsistency: 60
    case .incomeStability: 90
    case .spendingDiscipline: 0
    case .dataDepth: 0
    case .dataVerification: 0
    }
  }
}

enum FactorStatus: String, Sendable {
  case strong
  case good
  case activating
  case building

  var displayName: String {
    switch self {
    case .strong: "Strong"
    case .good: "Good"
    case .activating: "Activating"
    case .building: "Building"
    }
  }

  var backgroundColor: Color {
    switch self {
    case .strong, .good: Theme.Colors.tealWash
    case .activating: Theme.Colors.activatingBackground
    case .building: Theme.Colors.manualBadgeBackground
    }
  }

  var foregroundColor: Color {
    switch self {
    case .strong, .good: Theme.Colors.jewelTeal
    case .activating: Theme.Colors.gold
    case .building: Theme.Colors.taupeDark
    }
  }
}

struct FactorBreakdown: Equatable, Sendable {
  var factor: ScoreFactor
  var score: Double
  var status: FactorStatus
  var insufficientDataNote: String?
}

struct ScoreImprovementAction: Equatable, Sendable, Identifiable {
  var id: String
  var points: Int
  var timeframe: String
  var detail: String
}

struct ScoreSummary: Equatable, Sendable {
  var score: Int
  var tier: ScoreTier
  var indicativeOnly: Bool
  var monthlyDelta: Int
  var factors: [FactorBreakdown]
  var actions: [ScoreImprovementAction]
  var history: [Int]
  var historyMonthLabels: [String]
  var daysSinceJoin: Int
  var daysUntilRealScore: Int
  var summaryLine: String
  var nextMilestoneLine: String
}
