import Foundation

@MainActor
private func scoringJoinDate(stored: Date, entryCount: Int) -> Date {
  #if DEBUG
  if entryCount > 0 {
    return Calendar.current.date(byAdding: .day, value: -120, to: .now) ?? stored
  }
  #endif
  return stored
}

enum ScoreDataService {
  @MainActor
  static func loadSummary() -> ScoreSummary {
    #if DEBUG
    try? EntryRepository.liveValue.seedDemoData()
    #endif

    let entries = (try? EntryRepository.liveValue.fetchAll()) ?? []
    let storedJoinDate = (try? UserProfileRepository.liveValue.currentJoinDate()) ?? .now
    let joinDate = scoringJoinDate(stored: storedJoinDate, entryCount: entries.count)
    let snapshots = entries.map(ScoreEngineInput.EntrySnapshot.init(entry:))
    let verifiedCount = entries.filter { $0.verified }.count
    let input = ScoreEngineInput(
      joinDate: joinDate,
      entries: snapshots,
      verifiedSourceCount: verifiedCount > 0 ? 1 : 0,
      now: .now
    )

    let historyPoints = (try? ScoreSnapshotRepository.liveValue.monthlyHistory(6)) ?? []
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"

    var summary = ScoreEngine.computeSummary(
      input: input,
      historyScores: historyPoints.map(\.score),
      historyMonthLabels: historyPoints.map { formatter.string(from: $0.date) }
    )

    if ScoreEngine.hasRealScore(input: input) {
      try? ScoreSnapshotRepository.liveValue.recordSnapshot(summary, .now)
      let refreshedHistory = (try? ScoreSnapshotRepository.liveValue.monthlyHistory(6)) ?? historyPoints
      summary = ScoreEngine.computeSummary(
        input: input,
        historyScores: refreshedHistory.map(\.score),
        historyMonthLabels: refreshedHistory.map { formatter.string(from: $0.date) }
      )
    }

    return summary
  }
}
