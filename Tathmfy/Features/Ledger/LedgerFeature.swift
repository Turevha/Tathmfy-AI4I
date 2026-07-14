import ComposableArchitecture
import Foundation

struct LedgerEntryRow: Equatable, Identifiable, Sendable {
  var id: UUID
  var name: String
  var category: String
  var date: Date
  var isIncome: Bool
  var verified: Bool
  var amountDisplay: String
  var dateLabel: String
}

struct LedgerSection: Equatable, Sendable {
  var title: String
  var rows: [LedgerEntryRow]
}

@Reducer
struct LedgerFeature {
  @ObservableState
  struct State: Equatable {
    var sections: [LedgerSection] = []
    var isLoading = true
  }

  enum Action {
    case onAppear
    case loadResponse(sections: [LedgerSection])
    case dismissTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { @MainActor send in
          send(loadEntries())
        }

      case let .loadResponse(sections):
        state.sections = sections
        state.isLoading = false
        return .none

      case .dismissTapped:
        return .none
      }
    }
  }

  @MainActor
  private func loadEntries() -> Action {
    let entries = (try? EntryRepository.liveValue.fetchAll()) ?? []
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM"

    let grouped = Dictionary(grouping: entries) { entry -> Date in
      calendar.startOfDay(for: entry.date)
    }

    let sections = grouped.keys.sorted(by: >).map { day -> LedgerSection in
      let title: String
      if calendar.isDateInToday(day) {
        title = "Today"
      } else if calendar.isDateInYesterday(day) {
        title = "Yesterday"
      } else {
        title = formatter.string(from: day)
      }

      let rows = grouped[day]?
        .sorted { $0.date > $1.date }
        .map { entry in
          LedgerEntryRow(
            id: entry.id,
            name: entry.name,
            category: entry.category,
            date: entry.date,
            isIncome: entry.type == .income,
            verified: entry.verified,
            amountDisplay: LedgerFormatting.signedAmount(entry.amount, isIncome: entry.type == .income),
            dateLabel: formatter.string(from: entry.date)
          )
        } ?? []

      return LedgerSection(title: title, rows: rows)
    }

    return .loadResponse(sections: sections)
  }
}

enum LedgerFormatting {
  static func signedAmount(_ amount: Decimal, isIncome: Bool) -> String {
    let number = NSDecimalNumber(decimal: amount)
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    let formatted = formatter.string(from: number) ?? "$0"
    return isIncome ? "+\(formatted)" : "−\(formatted)"
  }
}
