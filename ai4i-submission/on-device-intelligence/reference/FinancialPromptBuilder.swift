import Foundation

/// Minimal financial snapshot for grounded chat — mirrors fields assembled in
/// `Tathmfy/Core/Chat/ChatFinancialContext.swift` without importing the app module.
struct FinancialSnapshot: Equatable, Sendable {
  var score: Int
  var indicativeOnly: Bool
  var daysSinceJoin: Int
  var daysUntilRealScore: Int
  var monthlyDelta: Int
  var incomeThisMonth: Decimal
  var spentThisMonth: Decimal
  var entryCount: Int
  var verifiedEntryCount: Int
  var topCategories: [String]
  var leadingFactor: String?
  var focusAction: String?
  var summaryLine: String
}

enum FinancialPromptBuilder {
  static let systemInstructions = """
    You are Tathmfy's on-device money assistant. Answer in 2-4 concise sentences.
    Use plain language. State key numbers clearly.
    Never claim data you don't have. Only use the user's snapshot below.
    Do not mention servers, cloud, or the internet.
    """

  static func userPrompt(question: String, snapshot: FinancialSnapshot) -> String {
    """
    \(snapshotContext(snapshot))

    User question: \(question)
    """
  }

  static func snapshotContext(_ snapshot: FinancialSnapshot) -> String {
    """
    User financial snapshot (on-device only):
    - Score: \(snapshot.score)\(snapshot.indicativeOnly ? " (indicative, not final)" : "")
    - Days active: \(snapshot.daysSinceJoin), days until real score: \(snapshot.daysUntilRealScore)
    - This month income: \(currency(snapshot.incomeThisMonth)), spent: \(currency(snapshot.spentThisMonth))
    - Entries logged: \(snapshot.entryCount), verified: \(snapshot.verifiedEntryCount)
    - Top spending categories: \(snapshot.topCategories.joined(separator: ", "))
    - Score summary: \(snapshot.summaryLine)
    - Leading factor: \(snapshot.leadingFactor ?? "still forming")
    - Suggested focus: \(snapshot.focusAction ?? "log weekly and verify one source")
    """
  }

  private static func currency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: value as NSDecimalNumber) ?? "$0"
  }
}
