import ComposableArchitecture
import SwiftUI

struct HomeView: View {
  @Bindable var store: StoreOf<HomeFeature>

  var body: some View {
    GeometryReader { geo in
      ScrollView {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
          header

          if store.isDayOneExperience {
            dayOneContent
          } else {
            activeContent
          }

          #if DEBUG
          if store.isDayOneExperience {
            Button("Load demo data") {
              store.send(.seedDemoDataTapped)
            }
            .font(Theme.Typography.label(14, weight: .semibold))
            .foregroundStyle(Theme.Colors.jewelTeal)
          }
          #endif
        }
        .padding(.horizontal, Theme.Layout.horizontalInset(for: geo.size.width))
        .padding(.top, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.lg)
        .frame(width: geo.size.width)
      }
      .background(Theme.Colors.bone)
      .onAppear { store.send(.onAppear) }
    }
  }

  private var header: some View {
    HStack {
      VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
        Text(store.isDayOneExperience ? store.greeting : formattedDate)
          .font(Theme.Typography.body(14, weight: .medium))
          .foregroundStyle(Theme.Colors.taupe)
        Text(store.isDayOneExperience ? store.userName : "Hi, \(store.userName)")
          .font(Theme.Typography.titleMedium)
          .foregroundStyle(Theme.Colors.espresso)
          .tracking(Theme.Typography.displayTracking)
      }
      Spacer()
      AvatarTile(initials: store.avatarInitials)
    }
  }

  private var dayOneContent: some View {
    Group {
      TathmfyCard(cornerRadius: Theme.Radius.cardLarge) {
        VStack(spacing: Theme.Spacing.sm) {
          ScoreDial(
            diameter: Theme.Size.dialHomeProgress,
            mode: .progress(currentDay: store.progressDay, totalDays: ScoreEngine.realScoreDayThreshold)
          )
          .padding(.bottom, 14)

          Text("Your score is forming")
            .font(Theme.Typography.ui(18, weight: .bold))
            .foregroundStyle(Theme.Colors.espresso)

          Text("30 days of activity and one verified source unlock your first real score.")
            .font(Theme.Typography.ui(13.5, weight: .medium))
            .foregroundStyle(Theme.Colors.taupeDark)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.top, 7)

          HStack(spacing: 7) {
            Text("Indicative estimate")
              .font(Theme.Typography.ui(12, weight: .semibold))
              .foregroundStyle(Color(hex: 0xA8412B))
            Text("~\(store.scoreSummary.score)")
              .font(Theme.Typography.display(14, weight: .heavy))
              .foregroundStyle(Theme.Colors.clay)
          }
          .padding(.horizontal, 13)
          .padding(.vertical, 7)
          .background(Theme.Colors.indicativeChipBackground)
          .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
          .padding(.top, 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 26)
      }

      HStack(spacing: Theme.Spacing.sm) {
        PrimaryButton(title: "Log entry", systemImage: "plus") { store.send(.logEntryTapped) }
        SecondaryButton(title: "Scan", systemImage: "camera") { store.send(.scanTapped) }
      }
      .padding(.top, Theme.Spacing.xs)

      SectionMicroLabel(title: "What builds your score")
        .padding(.top, Theme.Spacing.sm)

      HomeInfoCard(
        icon: "checkmark",
        iconBackground: Theme.Colors.tealWash,
        iconColor: Theme.Colors.jewelTeal,
        title: "Verified beats manual",
        bodyText: "Scans carry more scoring weight"
      )

      HomeInfoCard(
        icon: "clock",
        iconBackground: Theme.Colors.activatingBackground,
        iconColor: Theme.Colors.gold,
        title: "Show up regularly",
        bodyText: "Consistency is 35% of your score"
      )
    }
  }

  private var activeContent: some View {
    Group {
      VStack(spacing: 0) {
        HStack(alignment: .center, spacing: 18) {
          ScoreDial(
            diameter: Theme.Size.dialHomeCard,
            mode: .score(store.scoreSummary.score),
            appearance: .dark
          )
          .frame(width: Theme.Size.dialHomeCard, height: Theme.Size.dialHomeCard)

          VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            LiveScorePill()
            Text("▲ +\(store.scoreSummary.monthlyDelta) this month")
              .font(Theme.Typography.ui(16, weight: .bold))
              .foregroundStyle(Theme.Colors.goldAmber)
            Text(store.scoreSummary.nextMilestoneLine.replacingOccurrences(of: " · ", with: "\n"))
              .font(Theme.Typography.ui(13, weight: .medium))
              .foregroundStyle(Color(hex: 0xB8A793))
              .lineSpacing(2)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 17)
      }
      .background(Theme.Colors.espressoGradient)
      .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.cardLarge, style: .continuous))
      .themeShadow(
        Theme.ShadowStyle(color: Color(hex: 0x221911).opacity(0.22), radius: 30, x: 0, y: 14)
      )

      HStack(spacing: Theme.Spacing.sm) {
        PrimaryButton(title: "Log", systemImage: "plus", height: 48) { store.send(.logEntryTapped) }
        SecondaryButton(title: "Scan", height: 48) { store.send(.scanTapped) }
      }

      HStack {
        Text("Cash flow · \(monthName)")
          .font(Theme.Typography.label(14, weight: .bold))
          .foregroundStyle(Theme.Colors.espresso)
        Spacer()
        Button {
          store.send(.seeAllTapped)
        } label: {
          Text("See all")
            .font(Theme.Typography.label(13, weight: .semibold))
            .foregroundStyle(Theme.Colors.clay)
        }
        .buttonStyle(.plain)
      }
      .padding(.top, Theme.Spacing.xs)

      TathmfyCard(cornerRadius: Theme.Radius.card) {
        VStack(alignment: .leading, spacing: 13) {
          HStack(alignment: .top, spacing: 18) {
            statColumn(title: "Income", value: store.incomeDisplay, color: Theme.Colors.jewelTeal, dotColor: Theme.Colors.jewelTeal)
            statColumn(title: "Spent", value: store.spentDisplay, color: Theme.Colors.clay, dotColor: Theme.Colors.clay)
            statColumn(title: "Net saved", value: store.netDisplay, color: Theme.Colors.espresso, dotColor: nil, alignment: .trailing)
          }

          CashFlowChart(weeks: store.cashFlowWeeks)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
      }

      SectionMicroLabel(title: "Where your money goes")
        .padding(.top, Theme.Spacing.xxs)

      CategoryBreakdownView(categories: store.categorySpends)
    }
  }

  private func statColumn(
    title: String,
    value: String,
    color: Color,
    dotColor: Color?,
    alignment: HorizontalAlignment = .leading
  ) -> some View {
    VStack(alignment: alignment, spacing: 1) {
      if let dotColor {
        HStack(spacing: 5) {
          Circle().fill(dotColor).frame(width: 7, height: 7)
          Text(title)
            .font(Theme.Typography.ui(11, weight: .semibold))
            .foregroundStyle(Theme.Colors.taupe)
        }
      } else {
        Text(title)
          .font(Theme.Typography.ui(11, weight: .semibold))
          .foregroundStyle(Theme.Colors.taupe)
      }
      Text(value)
        .font(Theme.Typography.display(19, weight: .heavy))
        .foregroundStyle(color)
        .tracking(-0.01)
    }
    .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
  }

  private var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, d MMMM"
    return formatter.string(from: .now)
  }

  private var monthName: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter.string(from: .now)
  }
}

private struct AvatarTile: View {
  let initials: String

  var body: some View {
    Text(initials)
      .font(Theme.Typography.display(16, weight: .bold))
      .foregroundStyle(Color(hex: 0x5A3D12))
      .frame(width: 42, height: 42)
      .background(Theme.Colors.avatarBackground)
      .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
  }
}

#Preview("Day 1") {
  HomeView(store: Store(initialState: HomeFeature.State()) { HomeFeature() })
}

#Preview("Active") {
  HomeView(
    store: Store(
      initialState: {
        var state = HomeFeature.State()
        state.entryCount = 8
        state.isLoading = false
        state.scoreSummary = ScoreEngine.computeSummary(
          input: ScoreEngineInput(
            joinDate: Calendar.current.date(byAdding: .day, value: -120, to: .now) ?? .now,
            entries: DemoData.entries.map { draft in
              ScoreEngineInput.EntrySnapshot(
                type: draft.type,
                amount: draft.amount,
                category: draft.category,
                date: Calendar.current.date(byAdding: .day, value: -draft.daysAgo, to: .now) ?? .now,
                verified: draft.verified
              )
            },
            verifiedSourceCount: 1,
            now: .now
          )
        )
        return state
      }()
    ) {
      HomeFeature()
    }
  )
}
