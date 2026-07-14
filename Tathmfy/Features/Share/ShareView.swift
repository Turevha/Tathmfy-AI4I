import ComposableArchitecture
import SwiftUI

@Reducer
struct ShareFeature {
  @ObservableState
  struct State: Equatable {
    var holderName: String = "Amara Okonkwo"
    var score: Int = 712
    var tier: ScoreTier = .good
    var verificationCode: String = "TMN-694-A7X2"
    var issuedAt: Date = .now
    var sharePayload: String = ""
  }

  enum Action {
    case onAppear
    case loadCertificate(SignedCertificate, ScoreSummary)
    case shareCredentialTapped
    case downloadPDFTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        let holderName = state.holderName
        let fallbackCode = state.verificationCode
        return .run { @MainActor send in
          let summary = ScoreDataService.loadSummary()
          if let certificate = try? CertificateService.issueOrRefresh(
            holderName: holderName,
            score: summary.score
          ) {
            send(.loadCertificate(certificate, summary))
          } else {
            send(.loadCertificate(
              SignedCertificate(
                score: summary.score,
                holderName: holderName,
                issuedAt: .now,
                verificationCode: fallbackCode,
                signature: Data(),
                sharePayload: ""
              ),
              summary
            ))
          }
        }

      case let .loadCertificate(certificate, summary):
        state.score = summary.score
        state.tier = summary.tier
        state.verificationCode = certificate.verificationCode
        state.issuedAt = certificate.issuedAt
        state.sharePayload = certificate.sharePayload
        return .none

      case .shareCredentialTapped:
        let payload = state.sharePayload
        return .run { @MainActor _ in
          ShareExportService.presentShareSheet(payload: payload)
        }

      case .downloadPDFTapped:
        let certificate = SignedCertificate(
          score: state.score,
          holderName: state.holderName,
          issuedAt: state.issuedAt,
          verificationCode: state.verificationCode,
          signature: Data(),
          sharePayload: state.sharePayload
        )
        return .run { @MainActor _ in
          if let url = try? ShareExportService.writeCertificatePDF(certificate: certificate) {
            ShareExportService.presentPDF(url: url)
          }
        }
      }
    }
  }
}

struct ShareView: View {
  let store: StoreOf<ShareFeature>

  var body: some View {
    GeometryReader { geo in
      let scale = Theme.Layout.contentScale(for: geo.size.width)

      ScrollView {
        VStack(spacing: Theme.Spacing.lg) {
          headerBlock
          certificateCard(scale: scale)
          verifyLine
          PrimaryButton(title: "Share credential", systemImage: "square.and.arrow.up") {
            store.send(.shareCredentialTapped)
          }
          SecondaryButton(title: "Download PDF", systemImage: "arrow.down.doc") {
            store.send(.downloadPDFTapped)
          }
        }
        .padding(.horizontal, Theme.Layout.horizontalInset(for: geo.size.width))
        .padding(.bottom, Theme.Spacing.lg)
        .frame(width: geo.size.width)
      }
      .background(Theme.Colors.bone)
      .onAppear { store.send(.onAppear) }
    }
  }

  private var headerBlock: some View {
    VStack(spacing: 4) {
      Text("Share your score")
        .font(Theme.Typography.ui(19, weight: .bold))
        .foregroundStyle(Theme.Colors.espresso)
      Text("A signed credential — no data leaves your phone")
        .font(Theme.Typography.ui(13, weight: .medium))
        .foregroundStyle(Theme.Colors.taupeDark)
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .padding(.top, Theme.Spacing.sm)
  }

  private var verifyLine: some View {
    HStack(spacing: 7) {
      Image(systemName: "lock.fill")
        .font(.system(size: 12, weight: .semibold))
      Text("Lenders verify at ")
        .font(Theme.Typography.ui(12, weight: .medium))
      Text("tathmfy.com/verify")
        .font(Theme.Typography.label(12, weight: .bold))
    }
    .foregroundStyle(Theme.Colors.taupeDark)
  }

  private func certificateCard(scale: CGFloat) -> some View {
    let dialSize = 140 * scale

    return VStack(alignment: .leading, spacing: 18) {
      HStack {
        HStack(spacing: 9) {
          AppIconMark(size: 26, cornerRadius: 7)
          Text("Tathmfy")
            .font(Theme.Typography.wordmark(16))
            .foregroundStyle(Theme.Colors.bone)
        }
        Spacer()
        Text("Verified credit score")
          .font(Theme.Typography.micro(10, weight: .semibold))
          .foregroundStyle(Color(hex: 0x9BD8C7))
          .tracking(0.1)
          .textCase(.uppercase)
      }

      HStack(alignment: .center, spacing: 18) {
        ScoreDial(diameter: dialSize, mode: .score(store.score), appearance: .dark)
          .frame(width: dialSize, height: dialSize)

        VStack(alignment: .leading, spacing: 12) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Holder")
              .font(Theme.Typography.micro(11, weight: .medium))
              .foregroundStyle(Color(hex: 0x9A8770))
              .tracking(0.08)
              .textCase(.uppercase)
            Text(store.holderName)
              .font(Theme.Typography.ui(17, weight: .bold))
              .foregroundStyle(Theme.Colors.bone)
          }

          VStack(alignment: .leading, spacing: 2) {
            Text("Issued")
              .font(Theme.Typography.micro(11, weight: .medium))
              .foregroundStyle(Color(hex: 0x9A8770))
              .tracking(0.08)
              .textCase(.uppercase)
            Text(formattedDate(store.issuedAt))
              .font(Theme.Typography.ui(14, weight: .bold))
              .foregroundStyle(Color(hex: 0xE7D9C7))
          }
        }
      }

      DashedDivider()

      HStack(alignment: .bottom) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Verification code")
            .font(Theme.Typography.micro(10, weight: .medium))
            .foregroundStyle(Color(hex: 0x9A8770))
            .tracking(0.08)
            .textCase(.uppercase)
          Text(store.verificationCode)
            .font(Theme.Typography.display(18, weight: .bold))
            .foregroundStyle(Theme.Colors.goldAmber)
            .tracking(0.04)
        }
        Spacer()
        VStack(spacing: 4) {
          Image(systemName: "shield.checkered")
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(Theme.Colors.tealBright)
          Text("Secure Enclave")
            .font(Theme.Typography.micro(9, weight: .semibold))
            .foregroundStyle(Color(hex: 0x7F9E93))
        }
      }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 22)
    .background(
      LinearGradient(
        colors: [Color(hex: 0x2E2017), Color(hex: 0x241A12)],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.certificate, style: .continuous))
    .themeShadow(
      Theme.ShadowStyle(color: Color(hex: 0x221911).opacity(0.34), radius: 44, x: 0, y: 20)
    )
  }

  private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    return formatter.string(from: date)
  }
}

private struct DashedDivider: View {
  var body: some View {
    Rectangle()
      .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
      .foregroundStyle(Theme.Colors.bone.opacity(0.18))
      .frame(height: 1)
      .padding(.top, 2)
  }
}

#Preview {
  ShareView(store: Store(initialState: ShareFeature.State()) { ShareFeature() })
}
