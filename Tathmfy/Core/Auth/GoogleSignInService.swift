import Foundation
import GoogleSignIn
import UIKit

enum GoogleSignInService {
  static var isConfigured: Bool {
    clientID != nil
  }

  private static var clientID: String? {
    guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let clientID = plist["CLIENT_ID"] as? String else {
      return nil
    }
    return clientID
  }

  @MainActor
  static func configure() {
    guard let clientID else { return }
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
  }

  @MainActor
  static func signIn() async throws -> AuthenticatedUser {
    guard let clientID else {
      throw AuthError.notConfigured
    }

    if GIDSignIn.sharedInstance.configuration == nil {
      GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    guard let presenter = topViewController() else {
      throw AuthError.noPresentationContext
    }

    do {
      let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
      guard let profile = result.user.profile else {
        throw AuthError.profileMissing
      }

      let name = profile.name ?? "User"
      let email = profile.email ?? ""
      return AuthenticatedUser(
        name: name,
        email: email,
        avatarInitials: initials(from: name)
      )
    } catch let error as NSError where error.domain == "com.google.GIDSignIn" && error.code == -5 {
      throw AuthError.cancelled
    }
  }

  @MainActor
  static func handleURL(_ url: URL) -> Bool {
    GIDSignIn.sharedInstance.handle(url)
  }

  @MainActor
  private static func topViewController() -> UIViewController? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .rootViewController?
      .topMostViewController()
  }

  private static func initials(from name: String) -> String {
    let parts = name.split(separator: " ").prefix(2)
    let letters = parts.compactMap { $0.first.map(String.init) }.joined()
    return letters.isEmpty ? "U" : letters.uppercased()
  }
}

private extension UIViewController {
  func topMostViewController() -> UIViewController {
    if let presented = presentedViewController {
      return presented.topMostViewController()
    }
    if let navigation = self as? UINavigationController, let visible = navigation.visibleViewController {
      return visible.topMostViewController()
    }
    if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
      return selected.topMostViewController()
    }
    return self
  }
}
