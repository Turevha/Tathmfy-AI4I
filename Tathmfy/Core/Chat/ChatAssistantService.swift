import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum ChatAssistantService {
  @MainActor
  static func streamResponse(to prompt: String) -> AsyncThrowingStream<String, Error> {
    let context = ChatFinancialContext.load()

    if #available(iOS 26, *) {
      #if canImport(FoundationModels)
      if case .available = SystemLanguageModel.default.availability {
        return FoundationModelsChatAssistant.streamResponse(to: prompt, context: context)
      }
      #endif
    }

    return LocalChatAssistant.streamResponse(to: prompt, context: context)
  }
}

#if canImport(FoundationModels)
@available(iOS 26, *)
enum FoundationModelsChatAssistant {
  @MainActor
  static func streamResponse(
    to prompt: String,
    context: ChatFinancialContext
  ) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      Task {
        do {
          let session = LanguageModelSession(instructions: """
            You are Tathmfy's on-device money assistant. Answer in 2-4 concise sentences.
            Use plain language. Bold key numbers by writing them clearly.
            Never claim data you don't have. Only use the user's snapshot below.
            Do not mention servers, cloud, or the internet.
            """)
          let fullPrompt = """
            \(context.promptContext)

            User question: \(prompt)
            """
          let stream = session.streamResponse(to: fullPrompt)
          for try await chunk in stream {
            continuation.yield(chunk.content)
          }
          continuation.finish()
        } catch {
          let fallback = LocalChatAssistant.streamResponse(to: prompt, context: context)
          do {
            for try await chunk in fallback {
              continuation.yield(chunk)
            }
            continuation.finish()
          } catch {
            continuation.finish(throwing: error)
          }
        }
      }
    }
  }
}
#endif
