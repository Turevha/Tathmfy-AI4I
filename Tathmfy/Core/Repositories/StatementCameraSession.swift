import AVFoundation
import UIKit

enum StatementCameraError: Error, Equatable {
  case permissionDenied
  case unavailable
  case captureFailed
}

@MainActor
final class StatementCameraSession: NSObject, ObservableObject {
  let session = AVCaptureSession()

  private let photoOutput = AVCapturePhotoOutput()
  private var videoDevice: AVCaptureDevice?
  private var captureContinuation: CheckedContinuation<CGImage, Error>?

  static var isSimulator: Bool {
    #if targetEnvironment(simulator)
    true
    #else
    false
    #endif
  }

  func requestPermissionIfNeeded() async -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      return true
    case .notDetermined:
      return await AVCaptureDevice.requestAccess(for: .video)
    default:
      return false
    }
  }

  func configure() throws {
    guard !Self.isSimulator else { return }

    session.beginConfiguration()
    defer { session.commitConfiguration() }

    session.sessionPreset = .photo

    for input in session.inputs {
      session.removeInput(input)
    }
    for output in session.outputs {
      session.removeOutput(output)
    }

    guard
      let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
      let input = try? AVCaptureDeviceInput(device: device)
    else {
      throw StatementCameraError.unavailable
    }

    videoDevice = device

    guard session.canAddInput(input) else {
      throw StatementCameraError.unavailable
    }
    session.addInput(input)

    guard session.canAddOutput(photoOutput) else {
      throw StatementCameraError.unavailable
    }
    session.addOutput(photoOutput)
  }

  func start() {
    guard !Self.isSimulator, !session.isRunning else { return }
    DispatchQueue.global(qos: .userInitiated).async { [session] in
      session.startRunning()
    }
  }

  func stop() {
    setTorch(on: false)
    guard session.isRunning else { return }
    DispatchQueue.global(qos: .userInitiated).async { [session] in
      session.stopRunning()
    }
  }

  func setTorch(on: Bool) {
    guard let device = videoDevice, device.hasTorch else { return }
    do {
      try device.lockForConfiguration()
      device.torchMode = on ? .on : .off
      device.unlockForConfiguration()
    } catch {
      return
    }
  }

  func capturePhoto() async throws -> CGImage {
    if Self.isSimulator {
      return try StatementOCRService.simulatorSampleImage()
    }

    return try await withCheckedThrowingContinuation { continuation in
      captureContinuation = continuation
      let settings = AVCapturePhotoSettings()
      photoOutput.capturePhoto(with: settings, delegate: self)
    }
  }
}

extension StatementCameraSession: AVCapturePhotoCaptureDelegate {
  nonisolated func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    if let error {
      Task { @MainActor in
        captureContinuation?.resume(throwing: error)
        captureContinuation = nil
      }
      return
    }

    let image: CGImage? = {
      guard
        let data = photo.fileDataRepresentation(),
        let uiImage = UIImage(data: data)
      else {
        return nil
      }
      return uiImage.cgImage
    }()

    Task { @MainActor in
      defer { captureContinuation = nil }
      if let image {
        captureContinuation?.resume(returning: image)
      } else {
        captureContinuation?.resume(throwing: StatementCameraError.captureFailed)
      }
    }
  }
}
