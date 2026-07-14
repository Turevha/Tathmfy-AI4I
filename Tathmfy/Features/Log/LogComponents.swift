import SwiftUI

struct IncomeExpenseToggle: View {
  @Binding var isIncome: Bool

  var body: some View {
    HStack(spacing: 0) {
      toggleOption(title: "Income", selected: isIncome, activeColor: Theme.Colors.jewelTeal) {
        isIncome = true
      }
      toggleOption(title: "Expense", selected: !isIncome, activeColor: Theme.Colors.clay) {
        isIncome = false
      }
    }
    .padding(4)
    .background(Theme.Colors.track)
    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.input, style: .continuous))
  }

  private func toggleOption(
    title: String,
    selected: Bool,
    activeColor: Color,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Text(title)
        .font(Theme.Typography.label(14, weight: .bold))
        .foregroundStyle(selected ? activeColor : Theme.Colors.taupe)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.sm)
        .background(selected ? Theme.Colors.boneCard : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
  }
}

struct CategoryChipRow: View {
  let categories: [String]
  @Binding var selected: String

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(categories, id: \.self) { category in
          Button {
            selected = category
          } label: {
            Text(category)
              .font(Theme.Typography.ui(13, weight: .semibold))
              .foregroundStyle(selected == category ? .white : Theme.Colors.taupeDark)
              .lineLimit(1)
              .fixedSize(horizontal: true, vertical: false)
              .padding(.horizontal, 14)
              .padding(.vertical, 9)
              .background(selected == category ? Theme.Colors.clay : Theme.Colors.boneCard)
              .overlay {
                if selected != category {
                  Capsule().strokeBorder(Theme.Colors.sandLine, lineWidth: 1)
                }
              }
              .clipShape(Capsule())
          }
          .buttonStyle(.plain)
        }
      }
    }
    .frame(height: 38)
  }
}

struct NumericKeypad: View {
  let onDigit: (String) -> Void
  let onDelete: () -> Void

  private let rows = [
    ["1", "2", "3"],
    ["4", "5", "6"],
    ["7", "8", "9"],
    [".", "0", "⌫"],
  ]

  var body: some View {
    VStack(spacing: 6) {
      ForEach(rows, id: \.self) { row in
        HStack(spacing: 6) {
          ForEach(row, id: \.self) { key in
            Button {
              if key == "⌫" {
                onDelete()
              } else {
                onDigit(key)
              }
            } label: {
              Text(key == "⌫" ? "" : key)
                .font(Theme.Typography.display(26, weight: .semibold))
                .foregroundStyle(Theme.Colors.espresso)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .overlay {
                  if key == "⌫" {
                    Image(systemName: "delete.left")
                      .font(.system(size: 22, weight: .medium))
                      .foregroundStyle(Theme.Colors.taupeDark)
                  }
                }
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}
