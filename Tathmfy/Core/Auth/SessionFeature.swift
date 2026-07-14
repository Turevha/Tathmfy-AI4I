import ComposableArchitecture
import Foundation

enum AppPhase: Equatable, Sendable {
  case onboarding
  case signIn
  case main
}

@Reducer
struct SessionFeature {
  @ObservableState
  struct State: Equatable {
    var phase: AppPhase
    var user: AuthenticatedUser?
    var isSigningIn = false
    var signInError: String?

    init() {
      if UserDefaults.standard.bool(forKey: Keys.isAuthenticated) {
        phase = .main
        user = AuthenticatedUser(
          name: UserDefaults.standard.string(forKey: Keys.userName) ?? "Amara Okonkwo",
          email: UserDefaults.standard.string(forKey: Keys.userEmail) ?? "",
          avatarInitials: UserDefaults.standard.string(forKey: Keys.userInitials) ?? "AO"
        )
      } else if UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding) {
        phase = .signIn
      } else {
        phase = .onboarding
      }
    }
  }

  enum Action {
    case getStartedTapped
    case signInTapped
    case signInResponse(Result<AuthenticatedUser, Error>)
    case demoSignInTapped
    case signOut
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      @Dependency(\.authClient) var authClient

      switch action {
      case .getStartedTapped:
        UserDefaults.standard.set(true, forKey: Keys.hasSeenOnboarding)
        state.phase = .signIn
        return .none

      case .signInTapped:
        state.isSigningIn = true
        state.signInError = nil
        return .run { send in
          await send(.signInResponse(Result { try await authClient.signInWithGoogle() }))
        }

      case let .signInResponse(.success(user)):
        persist(user: user, state: &state)
        return .none

      case let .signInResponse(.failure(error)):
        state.isSigningIn = false
        state.signInError = error.localizedDescription
        return .none

      case .demoSignInTapped:
        return .send(
          .signInResponse(
            .success(
              AuthenticatedUser(
                name: "Amara Okonkwo",
                email: "amara@example.com",
                avatarInitials: "AO"
              )
            )
          )
        )

      case .signOut:
        UserDefaults.standard.removeObject(forKey: Keys.isAuthenticated)
        UserDefaults.standard.removeObject(forKey: Keys.userName)
        UserDefaults.standard.removeObject(forKey: Keys.userEmail)
        UserDefaults.standard.removeObject(forKey: Keys.userInitials)
        state.user = nil
        state.phase = .signIn
        state.isSigningIn = false
        state.signInError = nil
        return .none
      }
    }
  }

  private enum Keys {
    static let hasSeenOnboarding = "tathmfy.hasSeenOnboarding"
    static let isAuthenticated = "tathmfy.isAuthenticated"
    static let userName = "tathmfy.userName"
    static let userEmail = "tathmfy.userEmail"
    static let userInitials = "tathmfy.userInitials"
  }

  private func persist(user: AuthenticatedUser, state: inout State) {
    UserDefaults.standard.set(true, forKey: Keys.isAuthenticated)
    UserDefaults.standard.set(user.name, forKey: Keys.userName)
    UserDefaults.standard.set(user.email, forKey: Keys.userEmail)
    UserDefaults.standard.set(user.avatarInitials, forKey: Keys.userInitials)
    state.user = user
    state.phase = .main
    state.isSigningIn = false
    state.signInError = nil
  }
}
