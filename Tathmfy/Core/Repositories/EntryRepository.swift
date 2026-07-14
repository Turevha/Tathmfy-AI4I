import Foundation
import SwiftData

struct EntryRepository: Sendable {
  var fetchAll: @MainActor @Sendable () throws -> [Entry]
  var save: @MainActor @Sendable (Entry) throws -> Void
  var seedDemoData: @MainActor @Sendable () throws -> Void
  var count: @MainActor @Sendable () throws -> Int
}

extension EntryRepository {
  static var liveValue: EntryRepository {
    EntryRepository(
      fetchAll: { try sharedFetch() },
      save: { try sharedSave($0) },
      seedDemoData: { try sharedSeedDemo() },
      count: { try sharedCount() }
    )
  }

  static let previewValue = EntryRepository(
    fetchAll: { DemoData.entries.map { $0.asEntry() } },
    save: { _ in },
    seedDemoData: { },
    count: { DemoData.entries.count }
  )

  @MainActor private static func context() -> ModelContext {
    ModelContext(PersistenceController.modelContainer)
  }

  @MainActor private static func sharedFetch() throws -> [Entry] {
    let context = context()
    return try context.fetch(FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
  }

  @MainActor private static func sharedSave(_ entry: Entry) throws {
    let context = context()
    context.insert(entry)
    try context.save()
  }

  @MainActor private static func sharedCount() throws -> Int {
    try sharedFetch().count
  }

  @MainActor private static func sharedSeedDemo() throws {
    let context = context()
    let existing = try context.fetch(FetchDescriptor<Entry>())
    guard existing.isEmpty else { return }

    for draft in DemoData.entries {
      context.insert(draft.asEntry())
    }
    try context.save()
  }
}

enum DemoData {
  struct Draft {
    var type: EntryType
    var amount: Decimal
    var name: String
    var category: String
    var daysAgo: Int
    var verified: Bool

    func asEntry() -> Entry {
      Entry(
        type: type,
        amount: amount,
        name: name,
        category: category,
        date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now,
        source: verified ? .scan : .manual,
        verified: verified
      )
    }
  }

  static let entries: [Draft] = [
    Draft(type: .income, amount: 420, name: "Saturday stall takings", category: "Market sales", daysAgo: 1, verified: false),
    Draft(type: .expense, amount: 85, name: "Wholesale stock", category: "Wholesale stock", daysAgo: 2, verified: false),
    Draft(type: .income, amount: 340, name: "M-Pesa inflow", category: "Transfer", daysAgo: 4, verified: true),
    Draft(type: .expense, amount: 398, name: "Shop rent", category: "Rent", daysAgo: 6, verified: false),
    Draft(type: .expense, amount: 255, name: "Boda fares", category: "Transport", daysAgo: 8, verified: false),
    Draft(type: .income, amount: 520, name: "Market sales week", category: "Market sales", daysAgo: 10, verified: true),
    Draft(type: .expense, amount: 180, name: "Stock top-up", category: "Wholesale stock", daysAgo: 12, verified: false),
    Draft(type: .income, amount: 560, name: "Wages side job", category: "Wages", daysAgo: 15, verified: false),
  ]
}
