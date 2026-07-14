import ComposableArchitecture
import Foundation

struct AuthenticatedUser: Equatable, Sendable {
  var name: String
  var email: String
  var avatarInitials: String
}

struct AuthClient: Sendable {
  var signInWithGoogle: @Sendable () async throws -> AuthenticatedUser
}

extension AuthClient: DependencyKey {
  static let liveValue = AuthClient(
    signInWithGoogle: {
      try await GoogleSignInService.signIn()
    }
  )

  static let previewValue = AuthClient(
    signInWithGoogle: {
      AuthenticatedUser(name: "Amara Okonkwo", email: "amara@example.com", avatarInitials: "AO")
    }
  )
}

extension DependencyValues {
  var authClient: AuthClient {
    get { self[AuthClient.self] }
    set { self[AuthClient.self] = newValue }
  }
}

enum AuthError: LocalizedError {
  case notConfigured
  case cancelled
  case noPresentationContext
  case profileMissing

  var errorDescription: String? {
    switch self {
    case .notConfigured:
      "Google Sign-In is not configured yet. Add GoogleService-Info.plist and the reversed client ID URL scheme to Info.plist."
    case .cancelled:
      "Sign-in was cancelled."
    case .noPresentationContext:
      "Could not present Google Sign-In."
    case .profileMissing:
      "Google did not return a profile."
    }
  }
}
