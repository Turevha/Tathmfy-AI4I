import Foundation
import SwiftData

struct ScoreHistoryPoint: Equatable, Sendable {
  var date: Date
  var score: Int
}

struct ScoreSnapshotRepository: Sendable {
  var monthlyHistory: @MainActor @Sendable (Int) throws -> [ScoreHistoryPoint]
  var recordSnapshot: @MainActor @Sendable (ScoreSummary, Date) throws -> Void
}

extension ScoreSnapshotRepository {
  static var liveValue: ScoreSnapshotRepository {
    ScoreSnapshotRepository(
      monthlyHistory: { try sharedMonthlyHistory(limit: $0) },
      recordSnapshot: { try sharedRecordSnapshot(summary: $0, now: $1) }
    )
  }

  @MainActor private static func context() -> ModelContext {
    ModelContext(PersistenceController.modelContainer)
  }

  @MainActor private static func sharedMonthlyHistory(limit: Int) throws -> [ScoreHistoryPoint] {
    let snapshots = try context().fetch(
      FetchDescriptor<ScoreSnapshot>(sortBy: [SortDescriptor(\.date, order: .forward)])
    )

    let calendar = Calendar.current
    var byMonth: [DateComponents: ScoreSnapshot] = [:]

    for snapshot in snapshots {
      let components = calendar.dateComponents([.year, .month], from: snapshot.date)
      byMonth[components] = snapshot
    }

    return byMonth.values
      .sorted { $0.date < $1.date }
      .suffix(limit)
      .map { ScoreHistoryPoint(date: $0.date, score: $0.score) }
  }

  @MainActor private static func sharedRecordSnapshot(summary: ScoreSummary, now: Date) throws {
    guard !summary.indicativeOnly else { return }

    let context = context()
    let calendar = Calendar.current
    let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now

    let existing = try context.fetch(FetchDescriptor<ScoreSnapshot>()).filter {
      calendar.isDate($0.date, equalTo: monthStart, toGranularity: .month)
    }

    if let current = existing.last {
      current.date = now
      current.score = summary.score
      current.tier = summary.tier.rawValue
    } else {
      context.insert(
        ScoreSnapshot(
          date: now,
          score: summary.score,
          tier: summary.tier.rawValue
        )
      )
    }

    try context.save()
  }
}
