import ComposableArchitecture
import Foundation

struct ChatMessageRow: Equatable, Identifiable, Sendable {
  var id: UUID
  var role: ChatRole
  var text: String
  var isStreaming: Bool

  init(id: UUID = UUID(), role: ChatRole, text: String, isStreaming: Bool = false) {
    self.id = id
    self.role = role
    self.text = text
    self.isStreaming = isStreaming
  }

  init(message: ChatMessage) {
    self.init(id: message.id, role: message.role, text: message.text)
  }
}

@Reducer
struct ChatFeature {
  @ObservableState
  struct State: Equatable {
    var messages: [ChatMessageRow] = []
    var draft: String = ""
    var isLoading = true
    var isSending = false
    var errorMessage: String?

    static let suggestedPrompts = [
      "How did my spending affect my score?",
      "What should I focus on next?",
    ]
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case loadMessages([ChatMessageRow])
    case sendTapped
    case sendPrompt(String)
    case streamChunk(UUID, String)
    case streamFinished(UUID)
    case streamFailed(String)
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .onAppear:
        state.isLoading = true
        return .run { @MainActor send in
          let stored = (try? ChatMessageRepository.liveValue.fetchAll()) ?? []
          let rows = stored.map(ChatMessageRow.init(message:))
          send(.loadMessages(rows))
        }

      case let .loadMessages(rows):
        state.messages = rows
        state.isLoading = false
        return .none

      case .sendTapped:
        return sendMessage(state: &state, text: state.draft)

      case let .sendPrompt(prompt):
        return sendMessage(state: &state, text: prompt)

      case let .streamChunk(id, chunk):
        guard let index = state.messages.firstIndex(where: { $0.id == id }) else { return .none }
        state.messages[index].text += chunk
        return .none

      case let .streamFinished(id):
        state.isSending = false
        guard let index = state.messages.firstIndex(where: { $0.id == id }) else { return .none }
        state.messages[index].isStreaming = false
        let finalText = state.messages[index].text.trimmingCharacters(in: .whitespacesAndNewlines)
        return .run { @MainActor _ in
          guard !finalText.isEmpty else { return }
          try? ChatMessageRepository.liveValue.save(
            ChatMessage(id: id, role: .assistant, text: finalText)
          )
        }

      case let .streamFailed(message):
        state.isSending = false
        state.errorMessage = message
        if let index = state.messages.lastIndex(where: { $0.isStreaming }) {
          state.messages.remove(at: index)
        }
        return .none
      }
    }
  }

  private func sendMessage(state: inout State, text: String) -> Effect<Action> {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, !state.isSending else { return .none }

    state.draft = ""
    state.isSending = true
    state.errorMessage = nil

    let userRow = ChatMessageRow(role: .user, text: trimmed)
    state.messages.append(userRow)

    let assistantID = UUID()
    state.messages.append(ChatMessageRow(id: assistantID, role: .assistant, text: "", isStreaming: true))

    return .merge(
      .run { @MainActor _ in
        try? ChatMessageRepository.liveValue.save(
          ChatMessage(role: .user, text: trimmed)
        )
      },
      .run { send in
        do {
          let stream = await MainActor.run {
            ChatAssistantService.streamResponse(to: trimmed)
          }
          for try await chunk in stream {
            await send(.streamChunk(assistantID, chunk))
          }
          await send(.streamFinished(assistantID))
        } catch {
          await send(.streamFailed(error.localizedDescription))
        }
      }
    )
  }
}
