import SwiftUI

struct TathmfyCard<Content: View>: View {
  var cornerRadius: CGFloat = Theme.Radius.card
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .background(Theme.Colors.boneCard)
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .strokeBorder(Theme.Colors.sandLine, lineWidth: 1)
      }
      .themeShadow(Theme.Shadow.card)
  }
}

#Preview {
  TathmfyCard {
    Text("Card content")
      .font(Theme.Typography.bodyRegular)
      .foregroundStyle(Theme.Colors.espresso)
      .padding(Theme.Spacing.lg)
  }
  .padding()
  .background(Theme.Colors.bone)
}
