import Foundation
import SwiftUI

struct HomeDashboardData: Equatable, Sendable {
  var cashFlowWeeks: [CashFlowWeek]
  var incomeDisplay: String
  var spentDisplay: String
  var netDisplay: String
  var categorySpends: [CategorySpend]

  static let empty = HomeDashboardData(
    cashFlowWeeks: [],
    incomeDisplay: "$0",
    spentDisplay: "$0",
    netDisplay: "+$0",
    categorySpends: []
  )
}

enum EntryAnalytics {
  static func dashboard(from entries: [Entry], now: Date = .now) -> HomeDashboardData {
    let calendar = Calendar.current
    let monthEntries = entries.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }

    let incomeTotal = monthEntries.filter { $0.type == .income }.reduce(Decimal.zero) { $0 + $1.amount }
    let expenseTotal = monthEntries.filter { $0.type == .expense }.reduce(Decimal.zero) { $0 + $1.amount }
    let net = incomeTotal - expenseTotal

    return HomeDashboardData(
      cashFlowWeeks: weeklyCashFlow(from: entries, now: now),
      incomeDisplay: formatCurrency(incomeTotal),
      spentDisplay: formatCurrency(expenseTotal),
      netDisplay: formatSignedCurrency(net),
      categorySpends: categoryBreakdown(from: monthEntries)
    )
  }

  static func weeklyCashFlow(from entries: [Entry], now: Date) -> [CashFlowWeek] {
    let calendar = Calendar.current
    guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
      return []
    }

    return (0 ..< 6).reversed().map { offset in
      let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart) ?? now
      let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
      let weekEntries = entries.filter { $0.date >= weekStart && $0.date < weekEnd }
      let income = weekEntries.filter { $0.type == .income }.reduce(0.0) {
        $0 + (NSDecimalNumber(decimal: $1.amount).doubleValue)
      }
      let expense = weekEntries.filter { $0.type == .expense }.reduce(0.0) {
        $0 + (NSDecimalNumber(decimal: $1.amount).doubleValue)
      }
      let isCurrent = offset == 0
      let label = isCurrent ? "Now" : "W\(6 - offset)"
      return CashFlowWeek(id: label, income: income, expense: expense, isCurrent: isCurrent)
    }
  }

  static func categoryBreakdown(from entries: [Entry]) -> [CategorySpend] {
    let expenses = entries.filter { $0.type == .expense }
    let total = expenses.reduce(Decimal.zero) { $0 + $1.amount }
    guard total > 0 else { return [] }

    let grouped = Dictionary(grouping: expenses, by: \.category)
      .map { category, items -> (String, Decimal) in
        (category, items.reduce(Decimal.zero) { $0 + $1.amount })
      }
      .sorted { $0.1 > $1.1 }
      .prefix(3)

    return grouped.enumerated().map { index, item in
      let percentage = Int(
        ((item.1 as NSDecimalNumber).doubleValue / (total as NSDecimalNumber).doubleValue * 100)
          .rounded()
      )
      return CategorySpend(
        id: "\(index)-\(item.0)",
        name: item.0,
        amount: item.1,
        percentage: percentage,
        color: color(for: item.0, index: index)
      )
    }
  }

  private static func color(for category: String, index: Int) -> Color {
    switch category {
    case "Wholesale stock": Theme.Colors.clay
    case "Rent": Color(hex: 0xE0922E)
    case "Transport": Color(hex: 0xCDA24A)
    case "Market sales": Theme.Colors.jewelTeal
    default:
      [Theme.Colors.clay, Color(hex: 0xE0922E), Color(hex: 0xCDA24A)][index % 3]
    }
  }

  private static func formatCurrency(_ value: Decimal) -> String {
    let number = NSDecimalNumber(decimal: value)
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: number) ?? "$0"
  }

  private static func formatSignedCurrency(_ value: Decimal) -> String {
    let absolute = formatCurrency(value < 0 ? -value : value)
    if value > 0 { return "+\(absolute)" }
    if value < 0 { return "−\(absolute)" }
    return "+\(absolute)"
  }
}
