import ComposableArchitecture
import SwiftUI

struct LedgerView: View {
  @Bindable var store: StoreOf<LedgerFeature>
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Group {
        if store.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if store.sections.isEmpty {
          VStack(spacing: Theme.Spacing.sm) {
            Text("No entries yet")
              .font(Theme.Typography.ui(18, weight: .bold))
              .foregroundStyle(Theme.Colors.espresso)
            Text("Log income and expenses from Home to build your ledger.")
              .font(Theme.Typography.bodySmall)
              .foregroundStyle(Theme.Colors.taupeDark)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal, Theme.Spacing.lg)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          ScrollView {
            LazyVStack(alignment: .leading, spacing: Theme.Spacing.md) {
              ForEach(store.sections, id: \.title) { section in
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                  Text(section.title)
                    .font(Theme.Typography.label(13, weight: .bold))
                    .foregroundStyle(Theme.Colors.taupe)
                    .padding(.horizontal, Theme.Spacing.xxs)

                  VStack(spacing: 8) {
                    ForEach(section.rows) { row in
                      LedgerRowView(row: row)
                    }
                  }
                }
              }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
          }
        }
      }
      .background(Theme.Colors.bone)
      .navigationTitle("All entries")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            store.send(.dismissTapped)
            dismiss()
          }
          .font(Theme.Typography.label(15, weight: .semibold))
          .foregroundStyle(Theme.Colors.clay)
        }
      }
      .onAppear { store.send(.onAppear) }
    }
  }
}

private struct LedgerRowView: View {
  let row: LedgerEntryRow

  var body: some View {
    TathmfyCard(cornerRadius: Theme.Radius.card) {
      HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 3) {
          Text(row.name)
            .font(Theme.Typography.label(13.5, weight: .bold))
            .foregroundStyle(Theme.Colors.espresso)
          HStack(spacing: 6) {
            Text(row.category)
              .font(Theme.Typography.ui(11, weight: .semibold))
              .foregroundStyle(Theme.Colors.taupe)
            if row.verified {
              VerifiedBadge()
            } else {
              ManualBadge()
            }
          }
        }

        Spacer(minLength: 8)

        Text(row.amountDisplay)
          .font(Theme.Typography.display(16, weight: .heavy))
          .foregroundStyle(row.isIncome ? Theme.Colors.jewelTeal : Theme.Colors.espresso)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
    }
  }
}

#Preview {
  LedgerView(
    store: Store(initialState: LedgerFeature.State()) {
      LedgerFeature()
    }
  )
}
