import Foundation
import SwiftData

@Model
final class ScoreSnapshot {
  var id: UUID = UUID()
  var date: Date = Date()
  var score: Int = 300
  var tier: String = ScoreTier.building.rawValue
  var factorBreakdownJSON: Data?

  init(
    id: UUID = UUID(),
    date: Date = .now,
    score: Int,
    tier: String,
    factorBreakdownJSON: Data? = nil
  ) {
    self.id = id
    self.date = date
    self.score = score
    self.tier = tier
    self.factorBreakdownJSON = factorBreakdownJSON
  }
}
