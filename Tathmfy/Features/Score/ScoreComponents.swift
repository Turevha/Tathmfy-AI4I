import SwiftUI

struct FactorWeightRibbon: View {
  let factors: [FactorBreakdown]

  var body: some View {
    HStack(spacing: 3) {
      ForEach(factors, id: \.factor.id) { item in
        Rectangle()
          .fill(item.factor.color)
          .frame(maxWidth: .infinity)
          .layoutPriority(item.factor.weight)
      }
    }
    .frame(height: 15)
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }
}

struct ScoreHistoryChart: View {
  let values: [Int]

  var body: some View {
    GeometryReader { proxy in
      let maxValue = CGFloat(values.max() ?? 850)
      let minValue = CGFloat(values.min() ?? 300)
      let range = max(maxValue - minValue, 1)
      let stepX = proxy.size.width / CGFloat(max(values.count - 1, 1))

      let points: [CGPoint] = values.enumerated().map { index, value in
        point(
          index: index,
          value: value,
          stepX: stepX,
          height: proxy.size.height,
          minValue: minValue,
          range: range
        )
      }

      ZStack {
        if let first = points.first, let last = points.last {
          Path { path in
            path.move(to: CGPoint(x: first.x, y: proxy.size.height))
            path.addLine(to: first)
            for point in points.dropFirst() {
              path.addLine(to: point)
            }
            path.addLine(to: CGPoint(x: last.x, y: proxy.size.height))
            path.closeSubpath()
          }
          .fill(
            LinearGradient(
              colors: [Theme.Colors.clay.opacity(0.22), Theme.Colors.clay.opacity(0)],
              startPoint: .top,
              endPoint: .bottom
            )
          )

          Path { path in
            path.move(to: first)
            for point in points.dropFirst() {
              path.addLine(to: point)
            }
          }
          .stroke(Theme.Colors.clay, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }

        if let lastPoint = points.last {
          Circle()
            .fill(Color.white)
            .frame(width: 9, height: 9)
            .overlay {
              Circle().strokeBorder(Theme.Colors.jewelTeal, lineWidth: 2.5)
            }
            .position(lastPoint)
        }
      }
    }
    .frame(height: 92)
  }

  private func point(
    index: Int,
    value: Int,
    stepX: CGFloat,
    height: CGFloat,
    minValue: CGFloat,
    range: CGFloat
  ) -> CGPoint {
    let x = stepX * CGFloat(index)
    let y = height - ((CGFloat(value) - minValue) / range * height)
    return CGPoint(x: x, y: y)
  }
}

struct ImprovementActionCard: View {
  let action: ScoreImprovementAction

  var body: some View {
    HStack(alignment: .center, spacing: 13) {
      VStack(spacing: 2) {
        Text("+\(action.points)")
          .font(Theme.Typography.display(18, weight: .heavy))
          .foregroundStyle(Theme.Colors.jewelTeal)
        Text(action.timeframe.lowercased())
          .font(Theme.Typography.micro(9, weight: .semibold))
          .foregroundStyle(Theme.Colors.taupe)
          .tracking(0.06)
          .textCase(.uppercase)
      }
      .frame(minWidth: 46)

      VStack(alignment: .leading, spacing: 2) {
        Text(action.title)
          .font(Theme.Typography.label(13.5, weight: .bold))
          .foregroundStyle(Theme.Colors.espresso)
        Text(action.detail)
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

private extension ScoreImprovementAction {
  var title: String {
    switch id {
    case "income":
      "Log income 2 more weeks"
    case "verify":
      "Add a verified bank statement"
    case "consistency":
      "Keep spending under 60% of income"
    default:
      detail
    }
  }
}
