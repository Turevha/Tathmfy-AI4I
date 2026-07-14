import SwiftUI

struct TathmfyTabBar: View {
  let selectedTab: AppTab
  let onSelectTab: (AppTab) -> Void

  var body: some View {
    ZStack(alignment: .top) {
      tabBarBackground

      HStack(alignment: .bottom, spacing: 0) {
        ForEach(AppTab.allCases, id: \.self) { tab in
          tabItem(tab)
        }
      }
      .padding(.horizontal, Theme.Spacing.xs)
      .frame(height: Theme.Size.tabBarHeight)
    }
    .frame(height: Theme.Size.tabBarHeight)
    .themeShadow(Theme.Shadow.tabBar)
  }

  private var tabBarBackground: some View {
    ZStack(alignment: .top) {
      Rectangle()
        .fill(Theme.Colors.tabBarSurface)

      Rectangle()
        .fill(.thinMaterial)
        .opacity(0.35)

      Rectangle()
        .fill(Theme.Colors.tabBarBorder)
        .frame(height: 1)
    }
  }

  private func tabItem(_ tab: AppTab) -> some View {
    let isSelected = selectedTab == tab

    return Button {
      onSelectTab(tab)
    } label: {
      VStack(spacing: Theme.Spacing.xxs) {
        Image(systemName: tab.icon)
          .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
          .symbolRenderingMode(.monochrome)

        Text(tab.title)
          .font(Theme.Typography.micro(10, weight: isSelected ? .bold : .medium))
          .tracking(Theme.Typography.microTracking)
      }
      .foregroundStyle(isSelected ? Theme.Colors.clay : Theme.Colors.taupe)
      .frame(maxWidth: .infinity)
      .padding(.top, Theme.Spacing.sm)
      .padding(.bottom, Theme.Spacing.xs)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(tab.title)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var tab: AppTab = .home

    var body: some View {
      VStack {
        Spacer()
        Text("Selected: \(tab.title)")
          .font(Theme.Typography.bodyRegular)
          .foregroundStyle(Theme.Colors.espresso)
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Theme.Colors.bone)
      .safeAreaInset(edge: .bottom, spacing: 0) {
        TathmfyTabBar(selectedTab: tab, onSelectTab: { tab = $0 })
      }
    }
  }

  return PreviewWrapper()
}
