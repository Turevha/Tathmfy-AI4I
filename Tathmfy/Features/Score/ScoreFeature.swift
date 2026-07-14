import ComposableArchitecture
import Foundation

@Reducer
struct ScoreInsightsFeature {
  @ObservableState
  struct State: Equatable {
    var summary: ScoreSummary = ScoreEngine.computeSummary(input: .empty)
    var isLoading = true
  }

  enum Action {
    case onAppear
    case loadSummary(ScoreSummary)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { @MainActor send in
          let summary = ScoreDataService.loadSummary()
          send(.loadSummary(summary))
        }

      case let .loadSummary(summary):
        state.summary = summary
        state.isLoading = false
        return .none
      }
    }
  }
}
