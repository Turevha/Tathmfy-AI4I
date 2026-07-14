import Foundation
import SwiftData

enum EntryType: String, Codable, Sendable {
  case income
  case expense
}

enum EntrySource: String, Codable, Sendable {
  case manual
  case scan
  case statement
}

@Model
final class Entry {
  var id: UUID = UUID()
  var type: EntryType = EntryType.expense
  var amount: Decimal = 0
  var currencyCode: String = "USD"
  var name: String = ""
  var category: String = ""
  var date: Date = Date()
  var source: EntrySource = EntrySource.manual
  var verified: Bool = false
  var sourceRef: String?

  init(
    id: UUID = UUID(),
    type: EntryType,
    amount: Decimal,
    currencyCode: String = "USD",
    name: String,
    category: String,
    date: Date = .now,
    source: EntrySource,
    verified: Bool = false,
    sourceRef: String? = nil
  ) {
    self.id = id
    self.type = type
    self.amount = amount
    self.currencyCode = currencyCode
    self.name = name
    self.category = category
    self.date = date
    self.source = source
    self.verified = verified
    self.sourceRef = sourceRef
  }
}
