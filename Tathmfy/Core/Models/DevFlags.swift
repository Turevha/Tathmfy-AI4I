import Foundation

enum DevFlags {
  /// When true in DEBUG builds, demo entries are seeded on launch. Off by default so Day-1 is the default dev experience.
  static var seedDemoOnLaunch: Bool {
    #if DEBUG
    UserDefaults.standard.bool(forKey: "tathmfy.dev.seedDemoOnLaunch")
    #else
    false
    #endif
  }
}
