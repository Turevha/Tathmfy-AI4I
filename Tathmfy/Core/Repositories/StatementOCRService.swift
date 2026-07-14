import Foundation
import UIKit
import Vision

enum StatementOCRService {
  /// Sample rows for SwiftUI previews only.
  static func recognizePreviewStatement() -> [CameraScanFeature.ExtractedEntry] {
    [
      .init(id: UUID(), name: "Market sale", dateLabel: "12 Jun · M-Pesa", amount: 340, isIncome: true),
      .init(id: UUID(), name: "Rent", dateLabel: "14 Jun · M-Pesa", amount: 200, isIncome: false),
      .init(id: UUID(), name: "Market sale", dateLabel: "18 Jun · M-Pesa", amount: 275, isIncome: true),
    ]
  }

  /// Renders a statement-like image for Simulator OCR testing.
  static func simulatorSampleImage() throws -> CGImage {
    let lines = [
      "M-PESA STATEMENT",
      "12 Jun · Sale +340.00",
      "14 Jun · Rent -200.00",
      "18 Jun · Sale +275.00",
    ]
    let size = CGSize(width: 720, height: 960)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
      UIColor(red: 0.98, green: 0.97, blue: 0.94, alpha: 1).setFill()
      context.fill(CGRect(origin: .zero, size: size))

      let paragraph = NSMutableParagraphStyle()
      paragraph.lineBreakMode = .byWordWrapping

      var y: CGFloat = 48
      for (index, line) in lines.enumerated() {
        let fontSize: CGFloat = index == 0 ? 22 : 20
        let weight: UIFont.Weight = index == 0 ? .bold : .semibold
        let attributes: [NSAttributedString.Key: Any] = [
          .font: UIFont.systemFont(ofSize: fontSize, weight: weight),
          .foregroundColor: UIColor(red: 0.15, green: 0.11, blue: 0.09, alpha: 1),
          .paragraphStyle: paragraph,
        ]
        let rect = CGRect(x: 40, y: y, width: size.width - 80, height: 36)
        line.draw(in: rect, withAttributes: attributes)
        y += 44
      }
    }
    guard let cgImage = image.cgImage else {
      throw StatementCameraError.captureFailed
    }
    return cgImage
  }

  /// Runs Vision text recognition on a captured image. Returns an empty array when nothing is found.
  static func recognize(image: CGImage) async throws -> [CameraScanFeature.ExtractedEntry] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    try handler.perform([request])
    let lines = (request.results ?? [])
      .compactMap { $0.topCandidates(1).first?.string }

    return parseStatementLines(lines)
  }

  static func parseStatementLines(_ lines: [String]) -> [CameraScanFeature.ExtractedEntry] {
    var results: [CameraScanFeature.ExtractedEntry] = []

    for line in lines {
      guard let amountMatch = line.range(of: #"[+−-]\$?\d+(?:\.\d{1,2})?"#, options: .regularExpression) else {
        continue
      }
      let amountToken = String(line[amountMatch])
      let isIncome = amountToken.hasPrefix("+")
      let cleaned = amountToken
        .replacingOccurrences(of: "+", with: "")
        .replacingOccurrences(of: "−", with: "")
        .replacingOccurrences(of: "-", with: "")
        .replacingOccurrences(of: "$", with: "")
      guard let amount = Decimal(string: cleaned), amount > 0 else { continue }

      let label = line.replacingOccurrences(of: amountToken, with: "").trimmingCharacters(in: .whitespaces)
      let name = label.isEmpty ? "Statement entry" : label
      results.append(
        CameraScanFeature.ExtractedEntry(
          id: UUID(),
          name: name,
          dateLabel: "M-Pesa",
          amount: amount,
          isIncome: isIncome
        )
      )
    }

    return results
  }
}
