import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct TathmfyApp: App {
  @State private var store = Store(initialState: AppFeature.State()) {
    AppFeature()
  } withDependencies: {
    #if DEBUG
    if !GoogleSignInService.isConfigured {
      $0.authClient = .previewValue
    }
    #endif
  }

  init() {
    FontRegistration.registerBundledFonts()
    Task { @MainActor in
      GoogleSignInService.configure()
    }
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
        .onOpenURL { url in
          _ = GoogleSignInService.handleURL(url)
        }
    }
    .modelContainer(PersistenceController.modelContainer)
  }
}
