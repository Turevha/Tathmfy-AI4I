import Foundation
import SwiftData

enum ChatRole: String, Codable, Sendable {
  case user
  case assistant
}

@Model
final class ChatMessage {
  var id: UUID = UUID()
  var role: ChatRole = ChatRole.user
  var text: String = ""
  var createdAt: Date = Date()

  init(
    id: UUID = UUID(),
    role: ChatRole,
    text: String,
    createdAt: Date = .now
  ) {
    self.id = id
    self.role = role
    self.text = text
    self.createdAt = createdAt
  }
}
