import ComposableArchitecture
import SwiftUI

struct LogView: View {
  var body: some View {
    Color.clear
  }
}

struct ManualEntryView: View {
  @Bindable var store: StoreOf<ManualEntryFeature>

  var body: some View {
    VStack(spacing: 0) {
      manualHeader

      VStack(alignment: .leading, spacing: 0) {
        IncomeExpenseToggle(isIncome: $store.isIncome)
          .padding(.top, 10)

        Text("Amount")
          .font(Theme.Typography.micro(13, weight: .medium))
          .foregroundStyle(Theme.Colors.taupe)
          .tracking(0.1)
          .textCase(.uppercase)
          .padding(.top, 14)

        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text("$")
            .font(Theme.Typography.display(26, weight: .bold))
            .foregroundStyle(Theme.Colors.taupe)
          Text(store.amountDisplay.whole)
            .font(Theme.Typography.amount(60))
            .foregroundStyle(Theme.Colors.espresso)
            .tracking(Theme.Typography.tightTracking)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
          Text(".\(store.amountDisplay.cents)")
            .font(Theme.Typography.amount(60))
            .foregroundStyle(Theme.Colors.amountCentsMuted)
            .tracking(Theme.Typography.tightTracking)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)

        CategoryChipRow(categories: store.categories, selected: $store.selectedCategory)
          .padding(.top, 12)

        nameField
          .padding(.top, 12)

        Text(#"Name this entry — e.g. "Boda fares", "School fees""#)
          .font(Theme.Typography.ui(12, weight: .medium))
          .foregroundStyle(Theme.Colors.taupe)
          .padding(.top, 6)
      }
      .padding(.horizontal, 24)

      Spacer(minLength: 8)

      VStack(spacing: 10) {
        NumericKeypad(
          onDigit: { store.send(.digitTapped($0)) },
          onDelete: { store.send(.deleteTapped) }
        )

        PrimaryButton(
          title: store.isSaving ? "Saving…" : "Save entry",
          isEnabled: !store.isSaving,
          height: Theme.Size.primaryButtonHeightLarge
        ) {
          store.send(.saveTapped)
        }
      }
      .padding(.horizontal, 18)
      .padding(.bottom, 10)
    }
    .background(Theme.Colors.bone)
  }

  private var manualHeader: some View {
    HStack {
      Button("Cancel") { store.send(.cancelTapped) }
        .font(Theme.Typography.ui(15, weight: .semibold))
        .foregroundStyle(Theme.Colors.taupe)

      Spacer()

      Text("New entry")
        .font(Theme.Typography.ui(16, weight: .bold))
        .foregroundStyle(Theme.Colors.espresso)

      Spacer()

      Color.clear.frame(width: 54)
    }
    .padding(.horizontal, 24)
    .padding(.top, Theme.Spacing.sm)
  }

  private var nameField: some View {
    HStack(spacing: 11) {
      Image(systemName: "pencil")
        .font(.system(size: 17, weight: .medium))
        .foregroundStyle(Theme.Colors.taupe)

      TextField("Saturday stall takings", text: $store.name)
        .font(Theme.Typography.ui(15, weight: .semibold))
        .foregroundStyle(Theme.Colors.espresso)

      RoundedRectangle(cornerRadius: 2)
        .fill(Theme.Colors.clay)
        .frame(width: 2, height: 20)
        .opacity(store.name.isEmpty ? 1 : 0)
    }
    .padding(.horizontal, 16)
    .frame(height: Theme.Size.inputHeight)
    .background(Theme.Colors.boneCard)
    .overlay {
      RoundedRectangle(cornerRadius: Theme.Radius.input, style: .continuous)
        .strokeBorder(Theme.Colors.secondaryBorder, lineWidth: 1)
    }
    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.input, style: .continuous))
  }
}

struct CameraScanView: View {
  @Bindable var store: StoreOf<CameraScanFeature>
  @StateObject private var camera = StatementCameraSession()

  var body: some View {
    ZStack {
      cameraBackground

      VStack(spacing: 0) {
        scanTopBar
        Spacer()
        DocumentGuideFrame()
          .padding(.horizontal, 44)
        Text("Align the statement inside the frame")
          .font(Theme.Typography.ui(13, weight: .semibold))
          .foregroundStyle(Color(hex: 0xC7B8A6))
          .padding(.top, Theme.Spacing.md)
        Spacer()
        captureControls
          .padding(.bottom, 28)
      }

      if store.isProcessing {
        processingOverlay
      }

      if store.showError, let failure = store.failure {
        CameraErrorOverlay(
          failure: failure,
          onRetake: { store.send(.retakeTapped) },
          onEnterManually: { store.send(.enterManuallyTapped) }
        )
      }

      if store.showExtraction {
        ExtractionSheet(store: store)
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
    .onDisappear {
      camera.stop()
      store.send(.onDisappear)
    }
    .onChange(of: store.cameraIsActive) { _, isActive in
      if isActive {
        configureCameraIfNeeded()
        camera.start()
      } else {
        camera.stop()
      }
    }
    .onChange(of: store.isTorchOn) { _, isOn in
      camera.setTorch(on: isOn)
    }
    .onChange(of: store.phase) { _, phase in
      if phase == .processing {
        runCapture()
      }
    }
  }

  @ViewBuilder
  private var cameraBackground: some View {
    if store.cameraIsActive || store.showError {
      if StatementCameraSession.isSimulator {
        Color(hex: 0x1A1410).ignoresSafeArea()
      } else {
        CameraPreviewView(session: camera.session)
          .ignoresSafeArea()
      }
    }

    RadialGradient(
      colors: [Color.black.opacity(0.15), Color.black.opacity(0.55)],
      center: UnitPoint(x: 0.5, y: 0.35),
      startRadius: 0,
      endRadius: 500
    )
    .ignoresSafeArea()
    .allowsHitTesting(false)
  }

  private var scanTopBar: some View {
    HStack {
      Button { store.send(.cancelTapped) } label: {
        scanChip { Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)) }
      }
      Spacer()
      Text("Scan statement")
        .font(Theme.Typography.label(14, weight: .bold))
        .foregroundStyle(Theme.Colors.bone)
      Spacer()
      Button {
        store.send(.torchToggled)
      } label: {
        scanChip {
          Image(systemName: store.isTorchOn ? "bolt.fill" : "bolt.slash.fill")
            .font(.system(size: 16, weight: .semibold))
        }
      }
      .disabled(!store.cameraIsActive)
      .opacity(store.cameraIsActive ? 1 : 0.45)
    }
    .padding(.horizontal, 24)
    .padding(.top, Theme.Spacing.sm)
  }

  private var captureControls: some View {
    Button {
      store.send(.captureTapped)
    } label: {
      ZStack {
        Circle()
          .strokeBorder(Color.white.opacity(0.85), lineWidth: 4)
          .frame(width: 78, height: 78)
        Circle()
          .fill(Color.white)
          .frame(width: 62, height: 62)
      }
    }
    .buttonStyle(.plain)
    .disabled(!store.cameraIsActive || store.isProcessing)
    .opacity(store.cameraIsActive && !store.isProcessing ? 1 : 0.5)
    .accessibilityLabel("Capture statement")
  }

  private var processingOverlay: some View {
    ZStack {
      Color.black.opacity(0.45).ignoresSafeArea()
      VStack(spacing: 12) {
        ProgressView()
          .tint(.white)
        Text("Reading statement…")
          .font(Theme.Typography.ui(14, weight: .semibold))
          .foregroundStyle(.white)
      }
    }
  }

  private func configureCameraIfNeeded() {
    do {
      try camera.configure()
    } catch {
      store.send(.cameraSessionFailed)
    }
  }

  private func runCapture() {
    Task {
      do {
        let image = try await camera.capturePhoto()
        let entries = try await StatementOCRService.recognize(image: image)
        store.send(.photoProcessed(.success(entries)))
      } catch {
        store.send(.photoProcessed(.failure(.captureFailed)))
      }
    }
  }

  private func scanChip<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
      .foregroundStyle(Theme.Colors.bone)
      .frame(width: 34, height: 34)
      .background(Theme.Colors.bone.opacity(0.14))
      .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
  }
}

private struct CameraErrorOverlay: View {
  let failure: CameraScanFeature.CameraScanFailure
  let onRetake: () -> Void
  let onEnterManually: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.72).ignoresSafeArea()

      VStack(spacing: 18) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 34, weight: .semibold))
          .foregroundStyle(Theme.Colors.clay)

        Text(title)
          .font(Theme.Typography.ui(20, weight: .bold))
          .foregroundStyle(Theme.Colors.bone)
          .multilineTextAlignment(.center)

        Text(message)
          .font(Theme.Typography.ui(14, weight: .medium))
          .foregroundStyle(Color(hex: 0xC7B8A6))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 24)

        VStack(spacing: 10) {
          PrimaryButton(title: "Retake", height: 52, action: onRetake)
          SecondaryButton(title: "Enter manually", height: 52, action: onEnterManually)
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
      }
      .padding(.horizontal, 20)
    }
  }

  private var title: String {
    switch failure {
    case .permissionDenied:
      "Camera access needed"
    case .captureFailed, .noEntriesFound:
      "Couldn't read this document"
    }
  }

  private var message: String {
    switch failure {
    case .permissionDenied:
      "Allow camera access in Settings to scan statements, or enter amounts manually."
    case .captureFailed:
      "Try again with the statement flat, well lit, and fully inside the frame."
    case .noEntriesFound:
      "We couldn't find any amounts on this document. Retake the photo or add entries manually."
    }
  }
}

private struct DocumentGuideFrame: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        .background(Color.black.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

      cornerBracket(.topLeading)
      cornerBracket(.topTrailing)
      cornerBracket(.bottomLeading)
      cornerBracket(.bottomTrailing)
    }
    .frame(height: 300)
  }

  private func cornerBracket(_ corner: UnitPoint) -> some View {
    let size: CGFloat = 30
    return Group {
      switch corner {
      case .topLeading:
        Path { p in
          p.move(to: CGPoint(x: 0, y: size))
          p.addLine(to: .zero)
          p.addLine(to: CGPoint(x: size, y: 0))
        }
        .stroke(Theme.Colors.goldAmber, lineWidth: 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .offset(x: -3, y: -3)
      case .topTrailing:
        Path { p in
          p.move(to: CGPoint(x: 0, y: 0))
          p.addLine(to: CGPoint(x: size, y: 0))
          p.addLine(to: CGPoint(x: size, y: size))
        }
        .stroke(Theme.Colors.goldAmber, lineWidth: 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .offset(x: 3, y: -3)
      case .bottomLeading:
        Path { p in
          p.move(to: CGPoint(x: 0, y: 0))
          p.addLine(to: CGPoint(x: 0, y: size))
          p.addLine(to: CGPoint(x: size, y: size))
        }
        .stroke(Theme.Colors.goldAmber, lineWidth: 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .offset(x: -3, y: 3)
      case .bottomTrailing:
        Path { p in
          p.move(to: CGPoint(x: 0, y: size))
          p.addLine(to: CGPoint(x: size, y: size))
          p.addLine(to: CGPoint(x: size, y: 0))
        }
        .stroke(Theme.Colors.goldAmber, lineWidth: 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .offset(x: 3, y: 3)
      default:
        EmptyView()
      }
    }
  }
}

private struct ExtractionSheet: View {
  @Bindable var store: StoreOf<CameraScanFeature>

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        HStack(spacing: 10) {
          Image(systemName: "checkmark")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Theme.Colors.jewelTeal)
            .frame(width: 32, height: 32)
            .background(Theme.Colors.tealWash)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

          VStack(alignment: .leading, spacing: 2) {
            Text("Found \(store.entries.count) entries")
              .font(Theme.Typography.ui(16, weight: .bold))
              .foregroundStyle(Theme.Colors.espresso)
            Text("Verified source · tap any to edit")
              .font(Theme.Typography.ui(12, weight: .semibold))
              .foregroundStyle(Theme.Colors.jewelTeal)
          }
        }

        ForEach(store.entries) { entry in
          ExtractedEntryRow(
            entry: entry,
            isEditing: store.editingEntryID == entry.id,
            onTap: { store.send(.entryTapped(entry.id)) },
            onNameChange: { store.send(.entryNameChanged(entry.id, $0)) },
            onAmountChange: { store.send(.entryAmountTextChanged(entry.id, $0)) },
            onToggleIncome: { store.send(.entryIncomeToggled(entry.id)) }
          )
        }

        HStack(alignment: .top, spacing: 7) {
          Image(systemName: "info.circle")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Theme.Colors.taupe)
          Text("Check the amounts before saving — tap to correct anything")
            .font(Theme.Typography.ui(11.5, weight: .medium))
            .foregroundStyle(Theme.Colors.taupe)
        }
        .padding(.horizontal, 4)

        PrimaryButton(
          title: store.isConfirming ? "Saving…" : "Confirm & add",
          isEnabled: !store.isConfirming,
          height: 54
        ) {
          store.send(.confirmTapped)
        }
      }
      .padding(.horizontal, 22)
      .padding(.top, 22)
      .padding(.bottom, 26)
      .background(Theme.Colors.bone)
      .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sheet, style: .continuous))
      .padding(.horizontal, 14)
      .padding(.bottom, 14)
      .shadow(color: .black.opacity(0.4), radius: 40, y: -10)
    }
    .ignoresSafeArea(edges: .bottom)
  }
}

private struct ExtractedEntryRow: View {
  let entry: CameraScanFeature.ExtractedEntry
  let isEditing: Bool
  let onTap: () -> Void
  let onNameChange: (String) -> Void
  let onAmountChange: (String) -> Void
  let onToggleIncome: () -> Void

  private var formattedAmount: String {
    let prefix = entry.isIncome ? "+" : "−"
    return "\(prefix)$\(entry.amountEditText)"
  }

  var body: some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: 8) {
        if isEditing {
          TextField("Entry name", text: Binding(
            get: { entry.name },
            set: onNameChange
          ))
          .font(Theme.Typography.ui(14, weight: .bold))
          .foregroundStyle(Theme.Colors.espresso)

          HStack(spacing: 10) {
            TextField("Amount", text: Binding(
              get: { entry.amountEditText },
              set: onAmountChange
            ))
            .keyboardType(.decimalPad)
            .font(Theme.Typography.ui(14, weight: .bold))
            .foregroundStyle(Theme.Colors.espresso)

            Button(action: onToggleIncome) {
              Text(entry.isIncome ? "Income" : "Expense")
                .font(Theme.Typography.ui(12, weight: .bold))
                .foregroundStyle(entry.isIncome ? Theme.Colors.jewelTeal : Theme.Colors.clay)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                  (entry.isIncome ? Theme.Colors.tealWash : Theme.Colors.clay.opacity(0.12))
                )
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
          }
        } else {
          HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
              Text(entry.name)
                .font(Theme.Typography.label(13.5, weight: .bold))
                .foregroundStyle(Theme.Colors.espresso)
              Text(entry.dateLabel)
                .font(Theme.Typography.ui(11, weight: .semibold))
                .foregroundStyle(Theme.Colors.taupe)
            }
            Spacer()
            Text(formattedAmount)
              .font(Theme.Typography.label(14, weight: .bold))
              .foregroundStyle(entry.isIncome ? Theme.Colors.jewelTeal : Theme.Colors.espresso)
            Image(systemName: "pencil")
              .font(.system(size: 15, weight: .medium))
              .foregroundStyle(Theme.Colors.taupe)
          }
        }
      }
      .padding(.horizontal, 13)
      .padding(.vertical, 11)
      .background(Theme.Colors.boneCard)
      .overlay {
        RoundedRectangle(cornerRadius: 13, style: .continuous)
          .strokeBorder(
            isEditing ? Theme.Colors.clay : Theme.Colors.sandLine,
            lineWidth: isEditing ? 1.5 : 1
          )
      }
      .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
    .buttonStyle(.plain)
  }
}

#Preview("Manual") {
  ManualEntryView(
    store: Store(initialState: ManualEntryFeature.State()) {
      ManualEntryFeature()
    }
  )
}

#Preview("Camera") {
  CameraScanView(
    store: Store(initialState: CameraScanFeature.State()) {
      CameraScanFeature()
    }
  )
}
