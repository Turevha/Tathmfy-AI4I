import SwiftUI

struct TathmfyTextField: View {
  let placeholder: String
  @Binding var text: String
  var leadingIcon: String?

  var body: some View {
    HStack(spacing: Theme.Spacing.sm) {
      if let leadingIcon {
        Image(systemName: leadingIcon)
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(Theme.Colors.taupe)
      }

      TextField(placeholder, text: $text)
        .font(Theme.Typography.bodyRegular)
        .foregroundStyle(Theme.Colors.espresso)
    }
    .padding(.horizontal, Theme.Spacing.md)
    .frame(height: Theme.Size.inputHeight)
    .background(Theme.Colors.sandInput)
    .overlay {
      RoundedRectangle(cornerRadius: Theme.Radius.inputLarge, style: .continuous)
        .strokeBorder(Theme.Colors.secondaryBorder, lineWidth: 1)
    }
    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.inputLarge, style: .continuous))
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var text = ""

    var body: some View {
      TathmfyTextField(
        placeholder: "Saturday stall takings",
        text: $text,
        leadingIcon: "pencil"
      )
      .padding()
      .background(Theme.Colors.bone)
    }
  }

  return PreviewWrapper()
}
