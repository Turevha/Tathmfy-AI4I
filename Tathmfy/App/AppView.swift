import ComposableArchitecture
import SwiftUI

struct AppView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    Group {
      switch store.session.phase {
      case .onboarding:
        OnboardingView {
          store.send(.session(.getStartedTapped))
        }

      case .signIn:
        SignInView(
          isSigningIn: store.session.isSigningIn,
          errorMessage: store.session.signInError,
          onSignIn: { store.send(.session(.signInTapped)) },
          onDemoSignIn: { store.send(.session(.demoSignInTapped)) }
        )

      case .main:
        mainShell
      }
    }
    .animation(.easeInOut(duration: 0.25), value: store.session.phase)
  }

  private var mainShell: some View {
    tabContent
      .safeAreaInset(edge: .bottom, spacing: 0) {
        TathmfyTabBar(
          selectedTab: store.selectedTab,
          onSelectTab: { store.send(.tabSelected($0)) }
        )
      }
      .background(Theme.Colors.bone)
      .fullScreenCover(isPresented: manualSheetBinding) {
        ManualEntryView(
          store: store.scope(state: \.manualEntry, action: \.manualEntry)
        )
      }
      .fullScreenCover(isPresented: scanSheetBinding) {
        CameraScanView(
          store: store.scope(state: \.cameraScan, action: \.cameraScan)
        )
      }
      .sheet(isPresented: ledgerSheetBinding) {
        LedgerView(
          store: store.scope(state: \.ledger, action: \.ledger)
        )
      }
  }

  @ViewBuilder
  private var tabContent: some View {
    switch store.selectedTab {
    case .home:
      HomeView(store: store.scope(state: \.home, action: \.home))
    case .score:
      ScoreView(store: store.scope(state: \.score, action: \.score))
    case .share:
      ShareView(store: store.scope(state: \.share, action: \.share))
    case .chat:
      ChatView(store: store.scope(state: \.chat, action: \.chat))
    }
  }

  private var manualSheetBinding: Binding<Bool> {
    Binding(
      get: { store.manualEntryPresented },
      set: { store.send($0 ? .presentManualEntry : .dismissManualEntry) }
    )
  }

  private var scanSheetBinding: Binding<Bool> {
    Binding(
      get: { store.scanPresented },
      set: { store.send($0 ? .presentScan : .dismissScan) }
    )
  }

  private var ledgerSheetBinding: Binding<Bool> {
    Binding(
      get: { store.ledgerPresented },
      set: { store.send($0 ? .presentLedger : .dismissLedger) }
    )
  }
}

#Preview {
  AppView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    }
  )
}

#if DEBUG
#Preview("Component Gallery") {
  ComponentGalleryView()
}
#endif
