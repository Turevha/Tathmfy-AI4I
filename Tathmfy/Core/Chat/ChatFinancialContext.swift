import Foundation

struct ChatFinancialContext: Equatable, Sendable {
  var score: Int
  var indicativeOnly: Bool
  var daysSinceJoin: Int
  var daysUntilRealScore: Int
  var monthlyDelta: Int
  var incomeThisMonth: Decimal
  var spentThisMonth: Decimal
  var netThisMonth: Decimal
  var entryCount: Int
  var verifiedEntryCount: Int
  var topCategories: [String]
  var leadingFactor: String?
  var focusAction: String?
  var summaryLine: String

  @MainActor
  static func load() -> ChatFinancialContext {
    let summary = ScoreDataService.loadSummary()
    let entries = (try? EntryRepository.liveValue.fetchAll()) ?? []
    let calendar = Calendar.current
    let monthEntries = entries.filter {
      calendar.isDate($0.date, equalTo: Date.now, toGranularity: .month)
    }
    let income = monthEntries.filter { $0.type == .income }.reduce(Decimal.zero) { $0 + $1.amount }
    let spent = monthEntries.filter { $0.type == .expense }.reduce(Decimal.zero) { $0 + $1.amount }
    let categories = EntryAnalytics.dashboard(from: entries).categorySpends.map(\.name)
    let leading = summary.factors.first(where: { $0.status == .strong || $0.status == .good })?.factor.displayName
    let focus = summary.actions.first.map { "+\($0.points) \($0.detail)" }

    return ChatFinancialContext(
      score: summary.score,
      indicativeOnly: summary.indicativeOnly,
      daysSinceJoin: summary.daysSinceJoin,
      daysUntilRealScore: summary.daysUntilRealScore,
      monthlyDelta: summary.monthlyDelta,
      incomeThisMonth: income,
      spentThisMonth: spent,
      netThisMonth: income - spent,
      entryCount: entries.count,
      verifiedEntryCount: entries.filter(\.verified).count,
      topCategories: categories,
      leadingFactor: leading,
      focusAction: focus,
      summaryLine: summary.summaryLine
    )
  }

  var promptContext: String {
    """
    User financial snapshot (on-device only):
    - Score: \(score)\(indicativeOnly ? " (indicative, not final)" : "")
    - Days active: \(daysSinceJoin), days until real score: \(daysUntilRealScore)
    - This month income: \(currency(incomeThisMonth)), spent: \(currency(spentThisMonth)), net: \(signedCurrency(netThisMonth))
    - Entries logged: \(entryCount), verified: \(verifiedEntryCount)
    - Top spending categories: \(topCategories.joined(separator: ", "))
    - Score summary: \(summaryLine)
    - Leading factor: \(leadingFactor ?? "still forming")
    - Suggested focus: \(focusAction ?? "keep logging consistently")
    """
  }

  private func currency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: value as NSDecimalNumber) ?? "$0"
  }

  private func signedCurrency(_ value: Decimal) -> String {
    let absolute = currency(value < 0 ? -value : value)
    if value > 0 { return "+\(absolute)" }
    if value < 0 { return "−\(absolute)" }
    return "+\(absolute)"
  }
}
