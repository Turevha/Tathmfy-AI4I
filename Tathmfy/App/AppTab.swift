import Foundation

enum AppTab: String, CaseIterable, Equatable, Sendable {
  case home
  case score
  case share
  case chat

  var title: String {
    switch self {
    case .home: "Home"
    case .score: "Score"
    case .share: "Share"
    case .chat: "Chat"
    }
  }

  var icon: String {
    switch self {
    case .home: "house.fill"
    case .score: "gauge.with.dots.needle.67percent"
    case .share: "square.and.arrow.up"
    case .chat: "bubble.left.fill"
    }
  }
}
