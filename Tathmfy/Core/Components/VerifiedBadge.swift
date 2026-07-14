import SwiftUI

struct VerifiedBadge: View {
  var label: String = "Verified"

  var body: some View {
    HStack(spacing: Theme.Spacing.xs) {
      Circle()
        .fill(Theme.Colors.jewelTeal)
        .frame(width: Theme.Size.verifiedDot, height: Theme.Size.verifiedDot)

      Text(label)
        .font(Theme.Typography.badgeLabel)
        .foregroundStyle(Theme.Colors.jewelTeal)
    }
    .padding(.horizontal, Theme.Spacing.sm)
    .padding(.vertical, Theme.Spacing.xs)
    .background(Theme.Colors.tealWash)
    .clipShape(Capsule())
  }
}

#Preview {
  VerifiedBadge()
    .padding()
    .background(Theme.Colors.bone)
}
