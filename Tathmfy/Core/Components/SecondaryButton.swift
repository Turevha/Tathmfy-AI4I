import SwiftUI

struct SecondaryButton: View {
  let title: String
  var systemImage: String? = nil
  var height: CGFloat = Theme.Size.secondaryButtonHeight
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: Theme.Spacing.xs) {
        if let systemImage {
          Image(systemName: systemImage)
            .font(.system(size: 16, weight: .semibold))
        }
        Text(title)
          .font(Theme.Typography.buttonLabel)
      }
      .foregroundStyle(Theme.Colors.espresso)
      .frame(maxWidth: .infinity)
      .frame(height: height)
      .background(Theme.Colors.boneCard)
      .overlay {
        RoundedRectangle(cornerRadius: Theme.Radius.buttonLarge, style: .continuous)
          .strokeBorder(Theme.Colors.secondaryBorder, lineWidth: 1.5)
      }
      .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.buttonLarge, style: .continuous))
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  SecondaryButton(title: "Scan") {}
    .padding()
    .background(Theme.Colors.bone)
}
