import Foundation

struct ScoreEngineInput: Sendable {
  var joinDate: Date
  var entries: [EntrySnapshot]
  var verifiedSourceCount: Int
  var now: Date

  struct EntrySnapshot: Sendable {
    var type: EntryType
    var amount: Decimal
    var category: String
    var date: Date
    var verified: Bool
  }
}

enum ScoreEngine {
  static let minScore = 300
  static let maxScore = 850
  static let realScoreDayThreshold = 30

  static func daysSinceJoin(joinDate: Date, now: Date) -> Int {
    max(1, Calendar.current.dateComponents([.day], from: joinDate, to: now).day ?? 1)
  }

  static func hasRealScore(input: ScoreEngineInput) -> Bool {
    let days = daysSinceJoin(joinDate: input.joinDate, now: input.now)
    let verifiedEntries = input.entries.filter(\.verified).count
    return days >= realScoreDayThreshold && verifiedEntries > 0
  }

  static func indicativeEstimate(input: ScoreEngineInput) -> Int {
    640
  }

  static func computeScore(input: ScoreEngineInput) -> Int {
    if !hasRealScore(input: input) {
      return indicativeEstimate(input: input)
    }

    let days = daysSinceJoin(joinDate: input.joinDate, now: input.now)
    let factors = computeFactors(input: input, days: days)
    let weighted = factors.reduce(0.0) { partial, item in
      partial + item.score * item.factor.weight
    }
    return min(max(Int(weighted.rounded()), minScore), maxScore)
  }

  static func computeSummary(
    input: ScoreEngineInput,
    historyScores: [Int] = [],
    historyMonthLabels: [String] = []
  ) -> ScoreSummary {
    let days = daysSinceJoin(joinDate: input.joinDate, now: input.now)
    let indicativeOnly = !hasRealScore(input: input)
    let score = computeScore(input: input)
    let tier = ScoreTier.tier(for: score)
    let factors = computeFactors(input: input, days: days)
    let monthlyDelta = indicativeOnly ? 0 : monthlyScoreDelta(input: input, score: score)
    let history = indicativeOnly ? [] : historyScores
    let labels = indicativeOnly ? [] : historyMonthLabels

    return ScoreSummary(
      score: score,
      tier: tier,
      indicativeOnly: indicativeOnly,
      monthlyDelta: monthlyDelta,
      factors: factors,
      actions: defaultActions(days: days),
      history: history,
      historyMonthLabels: labels,
      daysSinceJoin: days,
      daysUntilRealScore: max(0, realScoreDayThreshold - days),
      summaryLine: summaryLine(factors: factors, days: days, input: input),
      nextMilestoneLine: nextMilestoneLine(days: days)
    )
  }

  static func daysUntilRealScore(joinDate: Date, now: Date) -> Int {
    max(0, realScoreDayThreshold - daysSinceJoin(joinDate: joinDate, now: now))
  }

  static func computeFactors(input: ScoreEngineInput, days: Int) -> [FactorBreakdown] {
    ScoreFactor.allCases.map { factor in
      let activated = days >= factor.activationDay
      let performance = factorPerformance(factor, input: input, days: days)
      let status: FactorStatus
      if !activated {
        status = .activating
      } else if performance >= 0.75 {
        status = .strong
      } else if performance >= 0.55 {
        status = .good
      } else if performance >= 0.35 {
        status = .building
      } else {
        status = .building
      }

      let score = activated
        ? Double(minScore) + Double(maxScore - minScore) * performance
        : Double(minScore + 120)
      let note = insufficientDataNote(for: factor, input: input, days: days, performance: performance)
      return FactorBreakdown(
        factor: factor,
        score: score,
        status: status,
        insufficientDataNote: note
      )
    }
  }

  static func insufficientDataNote(
    for factor: ScoreFactor,
    input: ScoreEngineInput,
    days: Int,
    performance: Double
  ) -> String? {
    guard days >= factor.activationDay else { return nil }

    switch factor {
    case .incomeStability:
      let incomeCount = input.entries.filter { $0.type == .income }.count
      if incomeCount < 4 {
        return "Not enough data yet · \(incomeCount) of 6 weeks of income"
      }
    case .paymentConsistency:
      if input.entries.isEmpty {
        return "Not enough data yet · log your first entry"
      }
    case .spendingDiscipline:
      let income = input.entries.filter { $0.type == .income }
      if income.isEmpty && performance < 0.4 {
        return "Not enough data yet · log income to measure spending"
      }
    case .dataDepth:
      if input.entries.count < 8 && performance < 0.35 {
        return "Not enough data yet · keep logging entries"
      }
    case .dataVerification:
      if input.entries.filter(\.verified).isEmpty {
        return "Not enough data yet · verify a source"
      }
    }

    return nil
  }

  private static func factorPerformance(
    _ factor: ScoreFactor,
    input: ScoreEngineInput,
    days: Int
  ) -> Double {
    let income = input.entries.filter { $0.type == .income }
    let expenses = input.entries.filter { $0.type == .expense }
    let verifiedRatio = input.entries.isEmpty
      ? 0
      : Double(input.entries.filter(\.verified).count) / Double(input.entries.count)

    switch factor {
    case .paymentConsistency:
      return min(1, Double(min(days, 90)) / 90.0) * 0.6 + verifiedRatio * 0.4
    case .incomeStability:
      return income.isEmpty ? 0.2 : min(1, Double(income.count) / 12.0)
    case .spendingDiscipline:
      let incomeTotal = income.reduce(Decimal.zero) { $0 + $1.amount }
      let expenseTotal = expenses.reduce(Decimal.zero) { $0 + $1.amount }
      guard incomeTotal > 0 else { return 0.25 }
      let ratio = (expenseTotal as NSDecimalNumber).doubleValue / (incomeTotal as NSDecimalNumber).doubleValue
      return max(0, min(1, 1.2 - ratio))
    case .dataDepth:
      return min(1, Double(input.entries.count) / 40.0)
    case .dataVerification:
      return verifiedRatio
    }
  }

  private static func summaryLine(factors: [FactorBreakdown], days: Int, input: ScoreEngineInput) -> String {
    if days < ScoreEngine.realScoreDayThreshold {
      let remaining = realScoreDayThreshold - days
      let verifiedCount = input.entries.filter(\.verified).count
      if verifiedCount == 0 {
        return "\(days)/\(realScoreDayThreshold) days in. \(remaining) days until your first real score — verify at least one source."
      }
      return "\(days)/\(realScoreDayThreshold) days in. \(remaining) days until your first real score."
    }
    if let leading = factors.first(where: { $0.status == .strong }) {
      return "\(leading.factor.displayName) is carrying your score. \(nextMilestoneLine(days: days))"
    }
    return "Keep logging to strengthen your score profile. \(nextMilestoneLine(days: days))"
  }

  static func nextMilestoneLine(days: Int) -> String {
    if days < 60 {
      let remaining = 60 - days
      return "Payment consistency activates in \(remaining) days."
    }
    if days < 90 {
      let remaining = 90 - days
      return "Income stability activates in \(remaining) days."
    }
    return "Your full scoring model is active."
  }

  private static func monthlyScoreDelta(input: ScoreEngineInput, score: Int) -> Int {
    let calendar = Calendar.current
    let thisMonth = input.entries.filter {
      calendar.isDate($0.date, equalTo: input.now, toGranularity: .month)
    }.count
    let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: input.now) ?? input.now
    let lastMonth = input.entries.filter {
      calendar.isDate($0.date, equalTo: lastMonthDate, toGranularity: .month)
    }.count
    return min(18, max(0, (thisMonth - lastMonth) * 3 + score / 40))
  }

  private static func defaultActions(days: Int) -> [ScoreImprovementAction] {
    [
      ScoreImprovementAction(
        id: "income",
        points: 22,
        timeframe: "by Aug",
        detail: "Activates income stability factor"
      ),
      ScoreImprovementAction(
        id: "verify",
        points: 15,
        timeframe: "today",
        detail: "Deepens data & verification"
      ),
      ScoreImprovementAction(
        id: "consistency",
        points: 9,
        timeframe: "30 days",
        detail: "Improves spending discipline"
      ),
    ]
    .filter { _ in days < 180 || true }
  }
}
