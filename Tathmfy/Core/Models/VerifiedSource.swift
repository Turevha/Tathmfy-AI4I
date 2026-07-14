import Foundation
import SwiftData

enum VerifiedSourceKind: String, Codable, Sendable {
  case mpesaStatement
  case bankStatement
  case other
}

@Model
final class VerifiedSource {
  var id: UUID = UUID()
  var kind: VerifiedSourceKind = VerifiedSourceKind.other
  var importedAt: Date = Date()
  var entryCount: Int = 0

  init(
    id: UUID = UUID(),
    kind: VerifiedSourceKind,
    importedAt: Date = .now,
    entryCount: Int = 0
  ) {
    self.id = id
    self.kind = kind
    self.importedAt = importedAt
    self.entryCount = entryCount
  }
}
