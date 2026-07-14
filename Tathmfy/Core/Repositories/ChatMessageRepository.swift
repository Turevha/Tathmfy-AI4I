import Foundation
import SwiftData

struct ChatMessageRepository: Sendable {
  var fetchAll: @MainActor @Sendable () throws -> [ChatMessage]
  var save: @MainActor @Sendable (ChatMessage) throws -> Void
}

extension ChatMessageRepository {
  static var liveValue: ChatMessageRepository {
    ChatMessageRepository(
      fetchAll: { try sharedFetchAll() },
      save: { try sharedSave($0) }
    )
  }

  @MainActor private static func context() -> ModelContext {
    ModelContext(PersistenceController.modelContainer)
  }

  @MainActor private static func sharedFetchAll() throws -> [ChatMessage] {
    try context().fetch(
      FetchDescriptor<ChatMessage>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
    )
  }

  @MainActor private static func sharedSave(_ message: ChatMessage) throws {
    let context = context()
    context.insert(message)
    try context.save()
  }
}
