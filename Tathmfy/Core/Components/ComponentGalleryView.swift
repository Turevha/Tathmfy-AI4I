import SwiftUI

#if DEBUG
struct ComponentGalleryView: View {
  @State private var entryName = ""

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
        Text("Component Library")
          .font(Theme.Typography.titleLarge)
          .foregroundStyle(Theme.Colors.espresso)
          .tracking(Theme.Typography.displayTracking)

        VStack(spacing: Theme.Spacing.sm) {
          PrimaryButton(title: "Primary button") {}
          SecondaryButton(title: "Secondary button") {}
        }

        HStack(spacing: Theme.Spacing.sm) {
          VerifiedBadge()
          ManualBadge()
        }

        TathmfyCard {
          VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Card")
              .font(Theme.Typography.sectionHeader)
              .foregroundStyle(Theme.Colors.espresso)
            Text("White surface, hairline border, soft shadow.")
              .font(Theme.Typography.bodySmall)
              .foregroundStyle(Theme.Colors.taupeDark)
          }
          .padding(Theme.Spacing.lg)
        }

        TathmfyTextField(
          placeholder: "Name this entry",
          text: $entryName,
          leadingIcon: "pencil"
        )

        Text("Score Dial")
          .font(Theme.Typography.sectionHeader)
          .foregroundStyle(Theme.Colors.espresso)

        ScoreDial(diameter: Theme.Size.dialScoreTab, mode: .score(712))
          .frame(maxWidth: .infinity)

        HStack(spacing: Theme.Spacing.lg) {
          VStack(spacing: Theme.Spacing.xs) {
            ScoreDial(diameter: Theme.Size.dialHomeCard, mode: .score(820))
            Text("820 · Excellent")
              .font(Theme.Typography.micro())
              .foregroundStyle(Theme.Colors.taupe)
          }

          VStack(spacing: Theme.Spacing.xs) {
            ScoreDial(diameter: Theme.Size.dialHomeCard, mode: .score(480))
            Text("480 · Building")
              .font(Theme.Typography.micro())
              .foregroundStyle(Theme.Colors.taupe)
          }
        }
        .frame(maxWidth: .infinity)

        VStack(spacing: Theme.Spacing.xs) {
          ScoreDial(diameter: Theme.Size.dialHomeProgress, mode: .progress(currentDay: 1))
          Text("Day 1 progress")
            .font(Theme.Typography.micro())
            .foregroundStyle(Theme.Colors.taupe)
        }
        .frame(maxWidth: .infinity)

        Text("Tab Bar")
          .font(Theme.Typography.sectionHeader)
          .foregroundStyle(Theme.Colors.espresso)

        TathmfyTabBar(selectedTab: .home, onSelectTab: { _ in })
      }
      .padding(Theme.Spacing.lg)
    }
    .background(Theme.Colors.bone)
  }
}

#Preview {
  ComponentGalleryView()
}
#endif
