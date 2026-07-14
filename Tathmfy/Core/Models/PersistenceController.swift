import SwiftData

enum PersistenceController {
  static let schema = Schema([
    Entry.self,
    VerifiedSource.self,
    ScoreSnapshot.self,
    Certificate.self,
    ChatMessage.self,
    UserProfile.self,
  ])

  static var modelContainer: ModelContainer {
    do {
      let configuration = ModelConfiguration(
        "TathmfyLocal",
        cloudKitDatabase: .none
      )
      return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
  }
}
