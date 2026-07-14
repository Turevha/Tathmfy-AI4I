import Foundation

/// Documents the intended provider selection order for Tathmfy chat.
///
/// Shipping app (`ChatAssistantService.swift`):
///   Foundation Models (if available) → LocalChatAssistant
///
/// Target architecture with Gemma integrated:
///   Foundation Models → Gemma3QuantizedEngine → LocalChatAssistant
enum LanguageModelRouter {
  @MainActor
  static func streamResponse(
    to prompt: String,
    snapshot: FinancialSnapshot
  ) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      Task {
        if await FoundationModelsChatProvider.shared.isAvailable {
          let stream = FoundationModelsChatProvider.shared.streamResponse(to: prompt, snapshot: snapshot)
          await relay(stream: stream, to: continuation)
          return
        }

        if await Gemma3QuantizedEngine.shared.isAvailable {
          let stream = Gemma3QuantizedEngine.shared.streamResponse(to: prompt, snapshot: snapshot)
          await relay(stream: stream, to: continuation)
          return
        }

        // Production uses LocalChatAssistant here — rules-based, fully offline, no LLM weights.
        let fallback = Gemma3QuantizedEngine.groundedPreviewResponse(for: prompt, snapshot: snapshot)
        for word in fallback.split(separator: " ") {
          continuation.yield(String(word) + " ")
        }
        continuation.finish()
      }
    }
  }

  @MainActor
  private static func relay(
    stream: AsyncThrowingStream<String, Error>,
    to continuation: AsyncThrowingStream<String, Error>.Continuation
  ) async {
    do {
      for try await chunk in stream {
        continuation.yield(chunk)
      }
      continuation.finish()
    } catch {
      continuation.finish(throwing: error)
    }
  }
}
