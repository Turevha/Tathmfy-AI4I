import AVFoundation
import ComposableArchitecture
import Foundation

@Reducer
struct LogFeature {
  @ObservableState
  struct State: Equatable {
    var manualPresented = false
    var scanPresented = false
  }

  enum Action {
    case showManual
    case showScan
    case manualDismissed
    case scanDismissed
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showManual:
        state.manualPresented = true
        return .none
      case .showScan:
        state.scanPresented = true
        return .none
      case .manualDismissed:
        state.manualPresented = false
        return .none
      case .scanDismissed:
        state.scanPresented = false
        return .none
      }
    }
  }
}

@Reducer
struct ManualEntryFeature {
  @ObservableState
  struct State: Equatable {
    var isIncome = true
    var amountDigits = "340"
    var name = ""
    var selectedCategory = "Market sales"
    var isSaving = false
    var didSave = false

    let categories = ["Market sales", "Wages", "Transfer", "Other"]

    var amountDisplay: (whole: String, cents: String) {
      let parts = amountDigits.split(separator: ".", omittingEmptySubsequences: false)
      let whole = String(parts.first ?? "0")
      let cents: String
      if parts.count > 1 {
        cents = String(parts[1].padding(toLength: 2, withPad: "0", startingAt: 0).prefix(2))
      } else {
        cents = "00"
      }
      return (whole, cents)
    }

    var decimalAmount: Decimal? {
      Decimal(string: amountDigits.isEmpty ? "0" : amountDigits)
    }
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case digitTapped(String)
    case deleteTapped
    case saveTapped
    case saveResponse(Result<Void, Error>)
    case cancelTapped
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .digitTapped(let digit):
        if digit == ".", state.amountDigits.contains(".") { return .none }
        if state.amountDigits == "0", digit != "." {
          state.amountDigits = digit
        } else {
          state.amountDigits += digit
        }
        return .none

      case .deleteTapped:
        if !state.amountDigits.isEmpty {
          state.amountDigits.removeLast()
        }
        return .none

      case .saveTapped:
        guard let amount = state.decimalAmount, amount > 0, !state.name.trimmingCharacters(in: .whitespaces).isEmpty else {
          return .none
        }
        state.isSaving = true
        let isIncome = state.isIncome
        let savedAmount = amount
        let name = state.name
        let category = state.selectedCategory
        return .run { @MainActor send in
          let store = EntryRepository.liveValue
          let entry = Entry(
            type: isIncome ? .income : .expense,
            amount: savedAmount,
            name: name,
            category: category,
            source: .manual,
            verified: false
          )
          do {
            try store.save(entry)
            send(.saveResponse(.success(())))
          } catch {
            send(.saveResponse(.failure(error)))
          }
        }

      case .saveResponse(.success):
        state.isSaving = false
        state.didSave = true
        return .none

      case .saveResponse(.failure):
        state.isSaving = false
        return .none

      case .cancelTapped:
        return .none

      case .binding:
        return .none
      }
    }
  }
}

@Reducer
struct CameraScanFeature {
  enum ScanPhase: Equatable {
    case loading
    case camera
    case processing
    case extraction
    case error(CameraScanFailure)
  }

  enum CameraScanFailure: Error, Equatable {
    case permissionDenied
    case captureFailed
    case noEntriesFound
  }

  @ObservableState
  struct State: Equatable {
    var phase: ScanPhase = .loading
    var entries: [ExtractedEntry] = []
    var editingEntryID: UUID?
    var isTorchOn = false
    var isConfirming = false

    var showExtraction: Bool {
      phase == .extraction
    }

    var showError: Bool {
      if case .error = phase { return true }
      return false
    }

    var isProcessing: Bool {
      phase == .processing
    }

    var cameraIsActive: Bool {
      phase == .camera || phase == .processing
    }

    var failure: CameraScanFailure? {
      if case let .error(failure) = phase { return failure }
      return nil
    }
  }

  struct ExtractedEntry: Equatable, Identifiable {
    var id: UUID
    var name: String
    var dateLabel: String
    var amount: Decimal
    var isIncome: Bool
    var amountEditText: String

    init(
      id: UUID = UUID(),
      name: String,
      dateLabel: String,
      amount: Decimal,
      isIncome: Bool
    ) {
      self.id = id
      self.name = name
      self.dateLabel = dateLabel
      self.amount = amount
      self.isIncome = isIncome
      self.amountEditText = NSDecimalNumber(decimal: amount).stringValue
    }
  }

  enum Action {
    case onAppear
    case onDisappear
    case permissionResponse(Bool)
    case cameraSessionFailed
    case captureTapped
    case photoProcessed(Result<[ExtractedEntry], CameraScanFailure>)
    case torchToggled
    case retakeTapped
    case enterManuallyTapped
    case entryTapped(UUID)
    case entryNameChanged(UUID, String)
    case entryAmountTextChanged(UUID, String)
    case entryIncomeToggled(UUID)
    case confirmTapped
    case confirmResponse(Result<Void, Error>)
    case cancelTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.phase = .loading
        state.entries = []
        state.editingEntryID = nil
        state.isTorchOn = false
        state.isConfirming = false
        return .run { send in
          let granted = await MainActor.run {
            AVCaptureDevice.authorizationStatus(for: .video)
          }
          let allowed: Bool
          switch granted {
          case .authorized:
            allowed = true
          case .notDetermined:
            allowed = await AVCaptureDevice.requestAccess(for: .video)
          default:
            allowed = false
          }
          await send(.permissionResponse(allowed))
        }

      case .onDisappear:
        state.isTorchOn = false
        return .none

      case let .permissionResponse(granted):
        if granted {
          state.phase = .camera
        } else {
          state.phase = .error(.permissionDenied)
        }
        return .none

      case .cameraSessionFailed:
        state.phase = .error(.captureFailed)
        return .none

      case .captureTapped:
        guard state.phase == .camera else { return .none }
        state.phase = .processing
        return .none

      case let .photoProcessed(.success(entries)):
        if entries.isEmpty {
          state.phase = .error(.noEntriesFound)
          state.entries = []
          state.editingEntryID = nil
        } else {
          state.entries = entries
          state.editingEntryID = entries.first?.id
          state.phase = .extraction
        }
        return .none

      case .photoProcessed(.failure):
        state.phase = .error(.captureFailed)
        return .none

      case .torchToggled:
        state.isTorchOn.toggle()
        return .none

      case .retakeTapped:
        state.entries = []
        state.editingEntryID = nil
        if case .error(.permissionDenied) = state.phase {
          state.phase = .loading
          return .run { send in
            let allowed = await AVCaptureDevice.requestAccess(for: .video)
            await send(.permissionResponse(allowed))
          }
        }
        state.phase = .camera
        return .none

      case .enterManuallyTapped:
        return .none

      case let .entryTapped(id):
        state.editingEntryID = id
        return .none

      case let .entryNameChanged(id, name):
        guard let index = state.entries.firstIndex(where: { $0.id == id }) else { return .none }
        state.entries[index].name = name
        return .none

      case let .entryAmountTextChanged(id, text):
        guard let index = state.entries.firstIndex(where: { $0.id == id }) else { return .none }
        state.entries[index].amountEditText = text
        let sanitized = text.filter { $0.isNumber || $0 == "." }
        if let amount = Decimal(string: sanitized), amount > 0 {
          state.entries[index].amount = amount
        }
        return .none

      case let .entryIncomeToggled(id):
        guard let index = state.entries.firstIndex(where: { $0.id == id }) else { return .none }
        state.entries[index].isIncome.toggle()
        return .none

      case .confirmTapped:
        guard !state.entries.isEmpty, !state.isConfirming else { return .none }
        state.isConfirming = true
        let drafts = state.entries
        return .run { @MainActor send in
          let store = EntryRepository.liveValue
          do {
            for draft in drafts {
              let entry = Entry(
                type: draft.isIncome ? .income : .expense,
                amount: draft.amount,
                name: draft.name,
                category: draft.isIncome ? "Transfer" : "Other",
                date: .now,
                source: .scan,
                verified: true,
                sourceRef: "M-Pesa"
              )
              try store.save(entry)
            }
            send(.confirmResponse(.success(())))
          } catch {
            send(.confirmResponse(.failure(error)))
          }
        }

      case .confirmResponse(.success):
        state.isConfirming = false
        return .none

      case .confirmResponse(.failure):
        state.isConfirming = false
        return .none

      case .cancelTapped:
        return .none
      }
    }
  }
}

private extension Substring {
  func padding(toLength length: Int, withPad pad: String, startingAt padIndex: Int) -> String {
    String(self).padding(toLength: length, withPad: pad, startingAt: padIndex)
  }
}
