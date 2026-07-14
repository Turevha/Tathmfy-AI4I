import SwiftUI

struct SectionMicroLabel: View {
  let title: String

  var body: some View {
    Text(title.uppercased())
      .font(Theme.Typography.micro(11, weight: .bold))
      .foregroundStyle(Theme.Colors.taupe)
      .tracking(0.1)
  }
}

struct LiveScorePill: View {
  @State private var isPulsing = false

  var body: some View {
    HStack(spacing: 6) {
      Circle()
        .fill(Theme.Colors.tealBright)
        .frame(width: 6, height: 6)
        .scaleEffect(isPulsing ? 1.25 : 0.85)
        .opacity(isPulsing ? 1 : 0.65)

      Text("Live score")
        .font(Theme.Typography.ui(11, weight: .semibold))
        .foregroundStyle(Color(hex: 0x9BD8C7))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Theme.Colors.tealBright.opacity(0.16))
    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    .onAppear {
      withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
        isPulsing = true
      }
    }
  }
}

struct CashFlowWeek: Identifiable, Equatable {
  var id: String
  var income: Double
  var expense: Double
  var isCurrent: Bool
}

struct CashFlowChart: View {
  let weeks: [CashFlowWeek]

  private var maxValue: Double {
    max(weeks.map { max($0.income, $0.expense) }.max() ?? 1, 1)
  }

  var body: some View {
    VStack(spacing: 7) {
      ZStack(alignment: .center) {
        Rectangle()
          .fill(Theme.Colors.sandLine)
          .frame(height: 1)

        HStack(alignment: .center, spacing: 9) {
          ForEach(weeks) { week in
            VStack(spacing: 0) {
              barColumn(value: week.income, isIncome: true, highlighted: week.isCurrent)
              barColumn(value: week.expense, isIncome: false, highlighted: week.isCurrent)
            }
            .frame(maxWidth: .infinity)
          }
        }
        .frame(height: 76)
      }

      HStack {
        ForEach(weeks) { week in
          Text(week.isCurrent ? "Now" : week.id)
            .font(Theme.Typography.micro(10, weight: week.isCurrent ? .bold : .semibold))
            .foregroundStyle(week.isCurrent ? Theme.Colors.gold : Color(hex: 0xB0A292))
            .frame(maxWidth: .infinity)
        }
      }
    }
  }

  private func barColumn(value: Double, isIncome: Bool, highlighted: Bool) -> some View {
    let height = max(8, 38 * value / maxValue)

    return Group {
      if isIncome {
        VStack(spacing: 0) {
          Spacer(minLength: 0)
          bar(height: height, isIncome: true, highlighted: highlighted)
        }
        .frame(height: 38)
      } else {
        VStack(spacing: 0) {
          bar(height: height, isIncome: false, highlighted: highlighted)
          Spacer(minLength: 0)
        }
        .frame(height: 38)
      }
    }
  }

  private func bar(height: CGFloat, isIncome: Bool, highlighted: Bool) -> some View {
    RoundedRectangle(cornerRadius: 4, style: .continuous)
      .fill(
        isIncome
          ? LinearGradient(
            colors: highlighted
              ? [Theme.Colors.goldAmber, Theme.Colors.gold]
              : [Color(hex: 0x2A8A78), Theme.Colors.jewelTeal],
            startPoint: .top,
            endPoint: .bottom
          )
          : LinearGradient(colors: [Theme.Colors.claySoft, Theme.Colors.claySoft], startPoint: .top, endPoint: .bottom)
      )
      .frame(width: 15, height: height)
      .overlay {
        if highlighted && isIncome {
          RoundedRectangle(cornerRadius: 4, style: .continuous)
            .strokeBorder(Theme.Colors.gold.opacity(0.18), lineWidth: 2)
            .padding(-2)
        }
      }
  }
}

struct CategorySpend: Identifiable, Equatable {
  var id: String
  var name: String
  var amount: Decimal
  var percentage: Int
  var color: Color
}

struct CategoryBreakdownView: View {
  let categories: [CategorySpend]

  var body: some View {
    VStack(spacing: 11) {
      ForEach(categories) { category in
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            Text(category.name)
              .font(Theme.Typography.label(13, weight: .bold))
              .foregroundStyle(Theme.Colors.espresso)
            Spacer()
          HStack(spacing: 0) {
            Text("$\(category.amount.formatted())")
              .font(Theme.Typography.label(13, weight: .bold))
              .foregroundStyle(Theme.Colors.espresso)
            Text(" · \(category.percentage)%")
              .font(Theme.Typography.label(13, weight: .semibold))
              .foregroundStyle(Theme.Colors.taupe)
          }
          }

          GeometryReader { proxy in
            ZStack(alignment: .leading) {
              Capsule().fill(Theme.Colors.trackAlt)
              Capsule()
                .fill(category.color)
                .frame(width: proxy.size.width * CGFloat(category.percentage) / 100)
            }
          }
          .frame(height: 8)
        }
      }
    }
  }
}

struct HomeInfoCard: View {
  let icon: String
  let iconBackground: Color
  let iconColor: Color
  let title: String
  let bodyText: String

  var body: some View {
    HStack(spacing: 13) {
      Image(systemName: icon)
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(iconColor)
        .frame(width: 34, height: 34)
        .background(iconBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(Theme.Typography.label(13.5, weight: .bold))
          .foregroundStyle(Theme.Colors.espresso)
        Text(bodyText)
          .font(Theme.Typography.ui(12, weight: .medium))
          .foregroundStyle(Theme.Colors.taupe)
      }
      Spacer(minLength: 0)
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 13)
    .background(Theme.Colors.boneCard)
    .overlay {
      RoundedRectangle(cornerRadius: 15, style: .continuous)
        .strokeBorder(Theme.Colors.sandLine, lineWidth: 1)
    }
    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
  }
}

private extension Decimal {
  func formatted() -> String {
    (self as NSDecimalNumber).stringValue
  }
}
