import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Mirrors the live production path in `FoundationModelsChatAssistant` inside
/// `Tathmfy/Core/Chat/ChatAssistantService.swift`.
enum FoundationModelsChatProvider: OnDeviceLanguageModelProviding {
  static let shared = FoundationModelsChatProvider()

  var displayName: String { "Apple Foundation Models" }

  var isAvailable: Bool {
    get async {
      guard #available(iOS 26, *) else { return false }
      #if canImport(FoundationModels)
      if case .available = SystemLanguageModel.default.availability {
        return true
      }
      #endif
      return false
    }
  }

  @MainActor
  func streamResponse(
    to userPrompt: String,
    snapshot: FinancialSnapshot
  ) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      Task {
        guard #available(iOS 26, *) else {
          continuation.finish(throwing: LanguageModelError.inferenceUnavailable)
          return
        }
        #if canImport(FoundationModels)
        guard case .available = SystemLanguageModel.default.availability else {
          continuation.finish(throwing: LanguageModelError.inferenceUnavailable)
          return
        }
        do {
          let session = LanguageModelSession(instructions: FinancialPromptBuilder.systemInstructions)
          let fullPrompt = FinancialPromptBuilder.userPrompt(question: userPrompt, snapshot: snapshot)
          let stream = session.streamResponse(to: fullPrompt)
          for try await chunk in stream {
            continuation.yield(chunk.content)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
        #else
        continuation.finish(throwing: LanguageModelError.inferenceUnavailable)
        #endif
      }
    }
  }
}
