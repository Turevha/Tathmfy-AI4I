import SwiftUI

struct PrimaryButton: View {
  let title: String
  var systemImage: String? = nil
  var isEnabled: Bool = true
  var height: CGFloat = Theme.Size.primaryButtonHeight
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: Theme.Spacing.xs) {
        if let systemImage {
          Image(systemName: systemImage)
            .font(.system(size: 16, weight: .bold))
        }
        Text(title)
          .font(Theme.Typography.buttonLabel)
      }
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .frame(height: height)
      .background(isEnabled ? Theme.Colors.clay : Theme.Colors.clay.opacity(0.45))
      .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.buttonLarge, style: .continuous))
      .themeShadow(Theme.Shadow.primaryButton)
    }
    .buttonStyle(.plain)
    .disabled(!isEnabled)
  }
}

#Preview {
  PrimaryButton(title: "Log entry") {}
    .padding()
    .background(Theme.Colors.bone)
}
