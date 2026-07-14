import ComposableArchitecture
import SwiftUI

struct ScoreView: View {
  @Bindable var store: StoreOf<ScoreInsightsFeature>

  var body: some View {
    GeometryReader { geo in
      let scale = Theme.Layout.contentScale(for: geo.size.width)

      ScrollView {
        VStack(spacing: Theme.Spacing.lg) {
          Text("Your score")
            .font(Theme.Typography.ui(18, weight: .bold))
            .foregroundStyle(Theme.Colors.espresso)
            .frame(maxWidth: .infinity)

          if store.isLoading {
            ScoreDialPlaceholder(diameter: Theme.Size.dialScoreHeader * scale)
              .padding(.top, 6)
          } else {
            ScoreDial(
              diameter: Theme.Size.dialScoreHeader * scale,
              mode: .score(store.summary.score)
            )
            .padding(.top, 6)
          }

          HStack(spacing: Theme.Spacing.sm) {
            deltaChip
            rangeChip
          }
          .padding(.top, -6)

          historyCard

          SectionMicroLabel(title: "What's driving your score")
            .frame(maxWidth: .infinity, alignment: .leading)

          drivingScoreCard

          SectionMicroLabel(title: "Improve your score")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Theme.Spacing.xxs)

          VStack(spacing: 9) {
            ForEach(store.summary.actions) { action in
              ImprovementActionCard(action: action)
            }
          }
        }
        .padding(.horizontal, Theme.Layout.horizontalInset(for: geo.size.width))
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, Theme.Spacing.lg)
        .frame(width: geo.size.width)
      }
      .background(Theme.Colors.bone)
      .onAppear { store.send(.onAppear) }
    }
  }

  private var deltaChip: some View {
    Text("▲ +\(store.summary.monthlyDelta) this month")
      .font(Theme.Typography.label(13, weight: .bold))
      .foregroundStyle(Theme.Colors.jewelTeal)
      .padding(.horizontal, 12)
      .padding(.vertical, 5)
      .background(Theme.Colors.tealWash)
      .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
  }

  private var rangeChip: some View {
    Text("300–850")
      .font(Theme.Typography.label(13, weight: .semibold))
      .foregroundStyle(Theme.Colors.taupe)
      .padding(.horizontal, 12)
      .padding(.vertical, 5)
      .background(Theme.Colors.boneCard)
      .overlay {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .strokeBorder(Theme.Colors.sandLineAlt, lineWidth: 1)
      }
      .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
  }

  private var historyCard: some View {
    TathmfyCard(cornerRadius: Theme.Radius.card) {
      VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
        HStack {
          Text("6-month history")
            .font(Theme.Typography.label(13, weight: .bold))
            .foregroundStyle(Theme.Colors.espresso)
          Spacer()
          if store.summary.history.count >= 2 {
            Text("\(store.summary.history.first ?? 0) → \(store.summary.history.last ?? 0)")
              .font(Theme.Typography.ui(12, weight: .semibold))
              .foregroundStyle(Theme.Colors.taupe)
          }
        }

        if store.summary.history.count >= 2 {
          ScoreHistoryChart(values: store.summary.history)
            .padding(.top, Theme.Spacing.xs)

          HStack {
            ForEach(historyLabels, id: \.self) { month in
              Text(month)
                .font(Theme.Typography.micro(10, weight: .semibold))
                .foregroundStyle(Color(hex: 0xB0A292))
                .frame(maxWidth: .infinity)
            }
          }
        } else {
          Text("Score history appears after your first real score.")
            .font(Theme.Typography.bodySmall)
            .foregroundStyle(Theme.Colors.taupeDark)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
    }
  }

  private var historyLabels: [String] {
    if store.summary.historyMonthLabels.count == store.summary.history.count {
      return store.summary.historyMonthLabels
    }
    return ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
  }

  private var drivingScoreCard: some View {
    TathmfyCard(cornerRadius: Theme.Radius.card) {
      VStack(alignment: .leading, spacing: 13) {
        summaryText

        FactorWeightRibbon(factors: store.summary.factors)

        VStack(spacing: 13) {
          ForEach(store.summary.factors, id: \.factor.id) { item in
            HStack(spacing: 11) {
              RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(item.factor.color)
                .frame(width: 10, height: 10)
              Text(item.factor.displayName)
                .font(Theme.Typography.label(13, weight: .bold))
                .foregroundStyle(Theme.Colors.espresso)
              Spacer()
              Text("\(Int(item.factor.weight * 100))%")
                .font(Theme.Typography.ui(11, weight: .semibold))
                .foregroundStyle(Theme.Colors.taupe)
              Text(item.status.displayName)
                .font(Theme.Typography.micro(11, weight: .bold))
                .foregroundStyle(item.status.foregroundColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(item.status.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
          }
        }
        .padding(.top, Theme.Spacing.xs)
      }
      .padding(16)
    }
  }

  private var summaryText: some View {
    Text(attributedSummary)
      .font(Theme.Typography.ui(13, weight: .semibold))
      .lineSpacing(3)
  }

  private var attributedSummary: AttributedString {
    var text = AttributedString(store.summary.summaryLine)
    if let range = text.range(of: "Income stability activates") {
      text[range].foregroundColor = Theme.Colors.taupe
    } else if let range = text.range(of: "Payment consistency activates") {
      text[range].foregroundColor = Theme.Colors.taupe
    }
    return text
  }
}

/// Keeps layout stable while score data loads so the dial only sweeps once.
private struct ScoreDialPlaceholder: View {
  let diameter: CGFloat

  var body: some View {
    Color.clear
      .frame(width: diameter, height: diameter)
  }
}

#Preview {
  ScoreView(
    store: Store(initialState: ScoreInsightsFeature.State()) {
      ScoreInsightsFeature()
    }
  )
}
