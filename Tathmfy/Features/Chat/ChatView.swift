import ComposableArchitecture
import SwiftUI

struct ChatView: View {
  @Bindable var store: StoreOf<ChatFeature>

  var body: some View {
    VStack(spacing: 0) {
      chatHeader

      Text("Runs entirely on your iPhone. Nothing leaves this device.")
        .font(Theme.Typography.ui(11.5, weight: .medium))
        .foregroundStyle(Theme.Colors.taupe)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)

      ScrollView {
        VStack(spacing: 10) {
          ChatBubble(
            text: "How did my spending affect my score in March?",
            isUser: true
          )

          ChatBubble(
            attributed: assistantMarchResponse,
            isUser: false
          )

          ChatBubble(
            text: "What should I focus on next?",
            isUser: true
          )

          ChatBubble(
            attributed: assistantFocusResponse,
            isUser: false
          )

          ForEach(store.messages) { message in
            if message.role == .user {
              ChatBubble(text: message.text, isUser: true)
            } else {
              ChatBubble(text: message.text.isEmpty && message.isStreaming ? "…" : message.text, isUser: false)
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
      }

      chatInputBar
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Theme.Colors.bone)
    }
    .background(Theme.Colors.bone)
    .onAppear { store.send(.onAppear) }
  }

  private var chatHeader: some View {
    HStack {
      Text("Assistant")
        .font(Theme.Typography.ui(18, weight: .bold))
        .foregroundStyle(Theme.Colors.espresso)
      Spacer()
      VerifiedBadge(label: "On-device · Private")
    }
    .padding(.horizontal, 22)
    .padding(.top, 6)
    .padding(.bottom, 10)
  }

  private var chatInputBar: some View {
    HStack(spacing: Theme.Spacing.sm) {
      TextField("Ask about your money…", text: $store.draft)
        .font(Theme.Typography.ui(14, weight: .medium))
        .padding(.horizontal, 18)
        .frame(height: 48)
        .background(Theme.Colors.boneCard)
        .overlay {
          Capsule().strokeBorder(Theme.Colors.secondaryBorder, lineWidth: 1)
        }
        .clipShape(Capsule())
        .disabled(store.isSending)
        .onSubmit { store.send(.sendTapped) }

      Button {
        store.send(.sendTapped)
      } label: {
        Image(systemName: "arrow.up")
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(.white)
          .frame(width: 48, height: 48)
          .background(Theme.Colors.clay)
          .clipShape(Circle())
          .themeShadow(Theme.ShadowStyle(color: Theme.Colors.clay.opacity(0.34), radius: 14, x: 0, y: 6))
      }
      .disabled(store.isSending || store.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
  }

  private var assistantMarchResponse: AttributedString {
    var text = AttributedString(
      "In March your spending-to-income ratio dropped to 58% — down from 71% in February. That lifted your spending discipline factor by about +8 points. Your three lowest-spend weeks all lined up with on-time bill payments, which helped payment consistency too."
    )
    if let range = text.range(of: "58%") {
      text[range].foregroundColor = Theme.Colors.jewelTeal
      text[range].font = Theme.Typography.ui(14, weight: .bold)
    }
    if let range = text.range(of: "+8 points") {
      text[range].foregroundColor = Theme.Colors.jewelTeal
      text[range].font = Theme.Typography.ui(14, weight: .bold)
    }
    if let range = text.range(of: "spending discipline") {
      text[range].font = Theme.Typography.ui(14, weight: .bold)
    }
    return text
  }

  private var assistantFocusResponse: AttributedString {
    var text = AttributedString(
      "Income stability. You've logged income 4 of the last 6 weeks. Two more consistent weeks would activate the full stability factor — worth roughly +22 points by August."
    )
    if let range = text.range(of: "Income stability.") {
      text[range].font = Theme.Typography.ui(14, weight: .bold)
    }
    if let range = text.range(of: "+22 points") {
      text[range].foregroundColor = Theme.Colors.jewelTeal
      text[range].font = Theme.Typography.ui(14, weight: .bold)
    }
    return text
  }
}

private struct ChatBubble: View {
  var text: String?
  var attributed: AttributedString?
  let isUser: Bool

  init(text: String, isUser: Bool) {
    self.text = text
    self.attributed = nil
    self.isUser = isUser
  }

  init(attributed: AttributedString, isUser: Bool) {
    self.text = nil
    self.attributed = attributed
    self.isUser = isUser
  }

  var body: some View {
    HStack {
      if isUser { Spacer(minLength: 40) }

      Group {
        if let attributed {
          Text(attributed)
        } else {
          Text(text ?? "")
        }
      }
      .font(Theme.Typography.ui(14, weight: .medium))
      .foregroundStyle(isUser ? Color.white : Theme.Colors.espresso)
      .lineSpacing(4)
      .padding(.horizontal, 15)
      .padding(.vertical, 12)
      .background(isUser ? Theme.Colors.clay : Theme.Colors.boneCard)
      .clipShape(
        UnevenRoundedRectangle(
          topLeadingRadius: 18,
          bottomLeadingRadius: isUser ? 18 : 5,
          bottomTrailingRadius: isUser ? 5 : 18,
          topTrailingRadius: 18,
          style: .continuous
        )
      )
      .overlay {
        if !isUser {
          UnevenRoundedRectangle(
            topLeadingRadius: 18,
            bottomLeadingRadius: 5,
            bottomTrailingRadius: 18,
            topTrailingRadius: 18,
            style: .continuous
          )
          .strokeBorder(Theme.Colors.sandLine, lineWidth: 1)
        }
      }
      .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)

      if !isUser { Spacer(minLength: 40) }
    }
  }
}

#Preview {
  ChatView(
    store: Store(initialState: ChatFeature.State()) {
      ChatFeature()
    }
  )
}
