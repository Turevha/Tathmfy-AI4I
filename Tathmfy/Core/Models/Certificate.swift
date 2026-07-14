import Foundation
import SwiftData

@Model
final class Certificate {
  var id: UUID = UUID()
  var score: Int = 300
  var holderName: String = ""
  var issuedAt: Date = Date()
  var verificationCode: String = ""
  var signature: Data = Data()

  init(
    id: UUID = UUID(),
    score: Int,
    holderName: String,
    issuedAt: Date = .now,
    verificationCode: String,
    signature: Data
  ) {
    self.id = id
    self.score = score
    self.holderName = holderName
    self.issuedAt = issuedAt
    self.verificationCode = verificationCode
    self.signature = signature
  }
}
