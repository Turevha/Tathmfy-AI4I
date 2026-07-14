import ComposableArchitecture

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var session: SessionFeature.State
    var selectedTab: AppTab = .home
    var home: HomeFeature.State
    var score = ScoreInsightsFeature.State()
    var share = ShareFeature.State()
    var ledger = LedgerFeature.State()
    var chat = ChatFeature.State()
    var manualEntry = ManualEntryFeature.State()
    var cameraScan = CameraScanFeature.State()
    var manualEntryPresented = false
    var scanPresented = false
    var ledgerPresented = false

    init() {
      let session = SessionFeature.State()
      var home = HomeFeature.State()
      var share = ShareFeature.State()

      if let user = session.user {
        Self.syncUser(user, home: &home, share: &share)
      }

      self.session = session
      self.selectedTab = .home
      self.home = home
      self.share = share
    }

    static func syncUser(
      _ user: AuthenticatedUser,
      home: inout HomeFeature.State,
      share: inout ShareFeature.State
    ) {
      let firstName = user.name.split(separator: " ").first.map(String.init) ?? user.name
      home.userName = firstName
      home.avatarInitials = user.avatarInitials
      share.holderName = user.name
    }
  }

  enum Action {
    case session(SessionFeature.Action)
    case tabSelected(AppTab)
    case presentManualEntry
    case dismissManualEntry
    case presentScan
    case dismissScan
    case presentLedger
    case dismissLedger
    case home(HomeFeature.Action)
    case score(ScoreInsightsFeature.Action)
    case share(ShareFeature.Action)
    case ledger(LedgerFeature.Action)
    case chat(ChatFeature.Action)
    case manualEntry(ManualEntryFeature.Action)
    case cameraScan(CameraScanFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.session, action: \.session) { SessionFeature() }
    Scope(state: \.home, action: \.home) { HomeFeature() }
    Scope(state: \.score, action: \.score) { ScoreInsightsFeature() }
    Scope(state: \.share, action: \.share) { ShareFeature() }
    Scope(state: \.ledger, action: \.ledger) { LedgerFeature() }
    Scope(state: \.chat, action: \.chat) { ChatFeature() }
    Scope(state: \.manualEntry, action: \.manualEntry) { ManualEntryFeature() }
    Scope(state: \.cameraScan, action: \.cameraScan) { CameraScanFeature() }

    Reduce { state, action in
      switch action {
      case let .tabSelected(tab):
        state.selectedTab = tab
        return .none

      case .presentManualEntry:
        state.manualEntryPresented = true
        return .none

      case .dismissManualEntry:
        state.manualEntryPresented = false
        state.manualEntry = ManualEntryFeature.State()
        return .none

      case .presentScan:
        state.scanPresented = true
        return .none

      case .dismissScan:
        state.scanPresented = false
        state.cameraScan = CameraScanFeature.State()
        return .none

      case .presentLedger:
        state.ledgerPresented = true
        return .none

      case .dismissLedger:
        state.ledgerPresented = false
        state.ledger = LedgerFeature.State()
        return .none

      case .home(.logEntryTapped):
        state.manualEntryPresented = true
        return .none

      case .home(.scanTapped):
        state.scanPresented = true
        return .none

      case .home(.seeAllTapped):
        state.ledgerPresented = true
        return .none

      case .manualEntry(.saveResponse(.success)):
        state.manualEntryPresented = false
        state.manualEntry = ManualEntryFeature.State()
        return AppFeature.refreshDataEffects()

      case .manualEntry(.cancelTapped):
        state.manualEntryPresented = false
        state.manualEntry = ManualEntryFeature.State()
        return .none

      case .cameraScan(.enterManuallyTapped):
        state.scanPresented = false
        state.cameraScan = CameraScanFeature.State()
        state.manualEntryPresented = true
        return .none

      case .cameraScan(.confirmResponse(.success)):
        state.scanPresented = false
        state.cameraScan = CameraScanFeature.State()
        return AppFeature.refreshDataEffects()

      case .cameraScan(.cancelTapped):
        state.scanPresented = false
        state.cameraScan = CameraScanFeature.State()
        return .none

      case .cameraScan(.confirmTapped):
        return .none

      case .ledger(.dismissTapped):
        state.ledgerPresented = false
        state.ledger = LedgerFeature.State()
        return .none

      case .session(.signInResponse(.success(let user))):
        var home = state.home
        var share = state.share
        State.syncUser(user, home: &home, share: &share)
        state.home = home
        state.share = share
        return .run { @MainActor send in
          if let joinDate = try? UserProfileRepository.liveValue.bootstrapProfile(
            user.name,
            user.avatarInitials
          ) {
            send(.home(.profileLoaded(name: home.userName, initials: home.avatarInitials, joinDate: joinDate)))
          }
        }

      case .session(.demoSignInTapped):
        return .none

      case .session(.signInResponse(.failure)):
        return .none

      case .session(.getStartedTapped), .session(.signInTapped), .session(.signOut):
        return .none

      case .session:
        return .none

      case .home, .score, .share, .ledger, .chat, .manualEntry, .cameraScan:
        return .none
      }
    }
  }
}
