import Foundation

/// Shared contract for every on-device language provider in Tathmfy.
/// Production entry point: `Tathmfy/Core/Chat/ChatAssistantService.swift`
protocol OnDeviceLanguageModelProviding: Sendable {
  var displayName: String { get }
  var isAvailable: Bool { get async }

  @MainActor
  func streamResponse(
    to userPrompt: String,
    snapshot: FinancialSnapshot
  ) -> AsyncThrowingStream<String, Error>
}

enum LanguageModelError: Error, LocalizedError {
  case modelNotBundled
  case modelLoadFailed(String)
  case inferenceUnavailable

  var errorDescription: String? {
    switch self {
    case .modelNotBundled:
      "Quantised model weights are not bundled in this build."
    case .modelLoadFailed(let reason):
      "Model load failed: \(reason)"
    case .inferenceUnavailable:
      "On-device language inference is unavailable on this device."
    }
  }
}
