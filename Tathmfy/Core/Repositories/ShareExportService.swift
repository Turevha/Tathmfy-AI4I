import Foundation
import UIKit

enum ShareExportService {
  @MainActor
  static func presentShareSheet(payload: String) {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController else {
      return
    }

    let controller = UIActivityViewController(activityItems: [payload], applicationActivities: nil)
    var presenter = root
    while let presented = presenter.presentedViewController {
      presenter = presented
    }
    presenter.present(controller, animated: true)
  }

  @MainActor
  static func writeCertificatePDF(certificate: SignedCertificate) throws -> URL {
    let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("Tathmfy-Credential-\(certificate.verificationCode).pdf")

    let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
    try renderer.writePDF(to: url) { context in
      context.beginPage()
      let title = "Tathmfy Verified Credit Score"
      let body = """
      Holder: \(certificate.holderName)
      Score: \(certificate.score)
      Issued: \(formattedDate(certificate.issuedAt))
      Verification: \(certificate.verificationCode)

      Lenders verify at tathmfy.com/verify
      """
      let titleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 24),
      ]
      let bodyAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 16),
      ]
      title.draw(at: CGPoint(x: 48, y: 72), withAttributes: titleAttributes)
      body.draw(
        in: CGRect(x: 48, y: 120, width: pageRect.width - 96, height: pageRect.height - 168),
        withAttributes: bodyAttributes
      )
    }
    return url
  }

  @MainActor
  static func presentPDF(url: URL) {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController else {
      return
    }

    let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    var presenter = root
    while let presented = presenter.presentedViewController {
      presenter = presented
    }
    presenter.present(controller, animated: true)
  }

  private static func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    return formatter.string(from: date)
  }
}
