import ComposableArchitecture
import Foundation

extension AppFeature {
  static func refreshDataEffects() -> Effect<Action> {
    .merge(
      .send(.home(.onAppear)),
      .send(.score(.onAppear)),
      .send(.share(.onAppear)),
      .send(.chat(.onAppear))
    )
  }
}
