import Foundation
import SwiftData

@Model
final class UserProfile {
  var id: UUID = UUID()
  var name: String = ""
  var avatarInitials: String = ""
  var joinDate: Date = Date()

  init(
    id: UUID = UUID(),
    name: String,
    avatarInitials: String,
    joinDate: Date = .now
  ) {
    self.id = id
    self.name = name
    self.avatarInitials = avatarInitials
    self.joinDate = joinDate
  }
}
