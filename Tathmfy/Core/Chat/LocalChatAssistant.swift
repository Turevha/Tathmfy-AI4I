import Foundation

enum LocalChatAssistant {
  @MainActor
  static func streamResponse(
    to prompt: String,
    context: ChatFinancialContext
  ) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      Task {
        let response = generateResponse(to: prompt, context: context)
        for word in response.split(separator: " ") {
          try await Task.sleep(for: .milliseconds(28))
          continuation.yield(word + " ")
        }
        continuation.finish()
      }
    }
  }

  @MainActor
  private static func generateResponse(to prompt: String, context: ChatFinancialContext) -> String {
    let normalized = prompt.lowercased()

    if normalized.contains("focus") || normalized.contains("next") || normalized.contains("improve") {
      return focusResponse(context)
    }

    if normalized.contains("spend") || normalized.contains("spent") || normalized.contains("march")
      || normalized.contains("month") || normalized.contains("cash") {
      return spendingResponse(context)
    }

    if normalized.contains("score") || normalized.contains("point") {
      return scoreResponse(context)
    }

    if normalized.contains("verify") || normalized.contains("scan") {
      return verificationResponse(context)
    }

    return generalResponse(context)
  }

  private static func spendingResponse(_ context: ChatFinancialContext) -> String {
    if context.entryCount == 0 {
      return "You haven't logged any entries yet. Start with one income and one expense this week — that unlocks spending discipline and gives your score something real to work with."
    }

    let ratio: Int
    if context.incomeThisMonth > 0 {
      ratio = Int(
        ((context.spentThisMonth as NSDecimalNumber).doubleValue
          / (context.incomeThisMonth as NSDecimalNumber).doubleValue * 100).rounded()
      )
    } else {
      ratio = 0
    }

    let categoryLine = context.topCategories.isEmpty
      ? "Log a few more expenses to see where your money goes."
      : "Your biggest categories this month are \(context.topCategories.joined(separator: ", "))."

    if context.indicativeOnly {
      return "This month you've logged \(currency(context.spentThisMonth)) in spending against \(currency(context.incomeThisMonth)) income — a \(ratio)% ratio. \(categoryLine) Once you hit 30 days with a verified source, this discipline feeds your real score."
    }

    return "This month your spending-to-income ratio is about \(ratio)% (\(currency(context.spentThisMonth)) spent vs \(currency(context.incomeThisMonth)) income). \(categoryLine) Keeping that ratio below ~70% tends to lift spending discipline — one of the fastest levers on your score."
  }

  private static func scoreResponse(_ context: ChatFinancialContext) -> String {
    if context.indicativeOnly {
      return "Your indicative score is around \(context.score). You're \(context.daysSinceJoin)/30 days in with \(context.daysUntilRealScore) days until your first real score. \(context.summaryLine)"
    }

    return "Your score is \(context.score). \(context.leadingFactor.map { "\($0) is one of your stronger factors right now." } ?? "Keep logging to strengthen your profile.") Monthly movement is about +\(context.monthlyDelta) points."
  }

  private static func focusResponse(_ context: ChatFinancialContext) -> String {
    if let focus = context.focusAction {
      return "Focus on \(focus). You have \(context.entryCount) entries logged and \(context.verifiedEntryCount) verified. Two more consistent weeks of income logging would help activate income stability — often worth +20 points or more."
    }
    return "Log income and expenses weekly, and verify at least one source with a scan. Consistency is 35% of your score — small regular entries beat occasional big dumps."
  }

  private static func verificationResponse(_ context: ChatFinancialContext) -> String {
    if context.verifiedEntryCount == 0 {
      return "You don't have a verified source yet. Scan an M-Pesa statement or receipt — verified entries carry more weight and are required before your first real score at day 30."
    }
    return "You have \(context.verifiedEntryCount) verified entries. Keep mixing scans with manual logs — verification is 5% of the model directly, and it increases trust in your other factors too."
  }

  private static func generalResponse(_ context: ChatFinancialContext) -> String {
    "Based on your data: score \(context.score), \(currency(context.incomeThisMonth)) income and \(currency(context.spentThisMonth)) spent this month. \(context.summaryLine) Ask me about spending, your score, or what to focus on next."
  }

  private static func currency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: value as NSDecimalNumber) ?? "$0"
  }
}
