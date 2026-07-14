import Foundation
import SwiftData

struct UserProfileRepository: Sendable {
  var currentJoinDate: @MainActor @Sendable () throws -> Date
  var bootstrapProfile: @MainActor @Sendable (_ name: String, _ initials: String) throws -> Date
}

extension UserProfileRepository {
  static var liveValue: UserProfileRepository {
    UserProfileRepository(
      currentJoinDate: { try sharedCurrentJoinDate() },
      bootstrapProfile: { try sharedBootstrapProfile(name: $0, initials: $1) }
    )
  }

  private enum Keys {
    static let joinDate = "tathmfy.joinDate"
  }

  @MainActor private static func context() -> ModelContext {
    ModelContext(PersistenceController.modelContainer)
  }

  @MainActor private static func sharedCurrentJoinDate() throws -> Date {
    if let profile = try fetchProfile() {
      return profile.joinDate
    }

    if let stored = UserDefaults.standard.string(forKey: Keys.joinDate),
       let date = ISO8601DateFormatter().date(from: stored) {
      return date
    }

    return Date.now
  }

  @MainActor private static func sharedBootstrapProfile(name: String, initials: String) throws -> Date {
    let context = context()

    if let existing = try fetchProfile(in: context) {
      existing.name = name
      existing.avatarInitials = initials
      try context.save()
      persistJoinDate(existing.joinDate)
      return existing.joinDate
    }

    let joinDate = Date.now
    context.insert(UserProfile(name: name, avatarInitials: initials, joinDate: joinDate))
    try context.save()
    persistJoinDate(joinDate)
    return joinDate
  }

  @MainActor private static func fetchProfile(in context: ModelContext? = nil) throws -> UserProfile? {
    let context = context ?? self.context()
    return try context.fetch(FetchDescriptor<UserProfile>()).first
  }

  private static func persistJoinDate(_ date: Date) {
    UserDefaults.standard.set(ISO8601DateFormatter().string(from: date), forKey: Keys.joinDate)
  }
}
