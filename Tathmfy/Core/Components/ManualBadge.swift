import SwiftUI

struct ManualBadge: View {
  var label: String = "Manual"

  var body: some View {
    HStack(spacing: Theme.Spacing.xs) {
      Circle()
        .strokeBorder(Theme.Colors.manualBadgeRing, lineWidth: 1.5)
        .frame(width: Theme.Size.manualRingSize, height: Theme.Size.manualRingSize)

      Text(label)
        .font(Theme.Typography.label(13, weight: .semibold))
        .foregroundStyle(Theme.Colors.taupe)
    }
    .padding(.horizontal, Theme.Spacing.sm)
    .padding(.vertical, Theme.Spacing.xs)
    .background(Theme.Colors.manualBadgeBackground)
    .clipShape(Capsule())
  }
}

#Preview {
  ManualBadge()
    .padding()
    .background(Theme.Colors.bone)
}
