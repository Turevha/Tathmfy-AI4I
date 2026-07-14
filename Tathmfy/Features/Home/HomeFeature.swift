import ComposableArchitecture
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

@Reducer
struct HomeFeature {
  @ObservableState
  struct State: Equatable {
    var userName: String = "Amara"
    var avatarInitials: String = "AO"
    var joinDate: Date = .now
    var entryCount: Int = 0
    var scoreSummary: ScoreSummary = ScoreEngine.computeSummary(input: .empty)
    var isLoading = true
    var cashFlowWeeks: [CashFlowWeek] = []
    var incomeDisplay: String = "$0"
    var spentDisplay: String = "$0"
    var netDisplay: String = "+$0"
    var categorySpends: [CategorySpend] = []

    var isDayOneExperience: Bool {
      entryCount == 0
    }

    var progressDay: Int {
      min(ScoreEngine.realScoreDayThreshold, scoreSummary.daysSinceJoin)
    }

    var daysUntilRealScore: Int {
      scoreSummary.daysUntilRealScore
    }

    var greeting: String {
      let hour = Calendar.current.component(.hour, from: .now)
      if hour < 12 { return "Good morning" }
      if hour < 17 { return "Good afternoon" }
      return "Good evening"
    }
  }

  enum Action {
    case onAppear
    case loadResponse(entryCount: Int, joinDate: Date, summary: ScoreSummary, dashboard: HomeDashboardData)
    case logEntryTapped
    case scanTapped
    case seeAllTapped
    case seedDemoDataTapped
    case profileLoaded(name: String, initials: String, joinDate: Date)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { @MainActor send in
          let store = EntryRepository.liveValue
          #if DEBUG
          try? store.seedDemoData()
          #endif
          send(loadSnapshot())
        }

      case let .loadResponse(count, joinDate, summary, dashboard):
        state.entryCount = count
        state.joinDate = joinDate
        state.scoreSummary = summary
        state.cashFlowWeeks = dashboard.cashFlowWeeks
        state.incomeDisplay = dashboard.incomeDisplay
        state.spentDisplay = dashboard.spentDisplay
        state.netDisplay = dashboard.netDisplay
        state.categorySpends = dashboard.categorySpends
        state.isLoading = false
        return .none

      case .logEntryTapped, .scanTapped, .seeAllTapped:
        return .none

      case let .profileLoaded(name, initials, joinDate):
        state.userName = name
        state.avatarInitials = initials
        state.joinDate = joinDate
        return .none

      case .seedDemoDataTapped:
        return .run { @MainActor send in
          try? EntryRepository.liveValue.seedDemoData()
          send(loadSnapshot())
        }
      }
    }
  }

  @MainActor
  private func loadSnapshot() -> Action {
    let dataStore = EntryRepository.liveValue
    let entries = (try? dataStore.fetchAll()) ?? []
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

    let dashboard = EntryAnalytics.dashboard(from: entries)
    return .loadResponse(
      entryCount: entries.count,
      joinDate: joinDate,
      summary: summary,
      dashboard: dashboard
    )
  }
}

extension ScoreEngineInput {
  static var empty: ScoreEngineInput {
    ScoreEngineInput(joinDate: .now, entries: [], verifiedSourceCount: 0, now: .now)
  }
}

extension ScoreEngineInput.EntrySnapshot {
  init(entry: Entry) {
    self.init(
      type: entry.type,
      amount: entry.amount,
      category: entry.category,
      date: entry.date,
      verified: entry.verified
    )
  }
}
