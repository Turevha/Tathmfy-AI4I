import CryptoKit
import Foundation
import SwiftData

struct SignedCertificate: Equatable, Sendable {
  var score: Int
  var holderName: String
  var issuedAt: Date
  var verificationCode: String
  var signature: Data
  var sharePayload: String
}

enum CertificateService {
  private static let signingKeyUserDefaultsKey = "tathmfy.certificate.signingKey"

  @MainActor
  static func issueOrRefresh(holderName: String, score: Int) throws -> SignedCertificate {
    let context = ModelContext(PersistenceController.modelContainer)
    let existing = try context.fetch(FetchDescriptor<Certificate>(sortBy: [SortDescriptor(\.issuedAt, order: .reverse)]))
      .first { $0.score == score && $0.holderName == holderName }

    if let existing {
      return map(existing)
    }

    let code = generateVerificationCode()
    let issuedAt = Date()
    let signature = try sign(score: score, holderName: holderName, issuedAt: issuedAt, code: code)
    let certificate = Certificate(
      score: score,
      holderName: holderName,
      issuedAt: issuedAt,
      verificationCode: code,
      signature: signature
    )
    context.insert(certificate)
    try context.save()
    return map(certificate)
  }

  @MainActor
  static func latestCertificate() throws -> SignedCertificate? {
    let context = ModelContext(PersistenceController.modelContainer)
    guard let certificate = try context.fetch(
      FetchDescriptor<Certificate>(sortBy: [SortDescriptor(\.issuedAt, order: .reverse)])
    ).first else {
      return nil
    }
    return map(certificate)
  }

  private static func map(_ certificate: Certificate) -> SignedCertificate {
    SignedCertificate(
      score: certificate.score,
      holderName: certificate.holderName,
      issuedAt: certificate.issuedAt,
      verificationCode: certificate.verificationCode,
      signature: certificate.signature,
      sharePayload: sharePayload(
        score: certificate.score,
        holderName: certificate.holderName,
        issuedAt: certificate.issuedAt,
        code: certificate.verificationCode,
        signature: certificate.signature
      )
    )
  }

  static func sharePayload(
    score: Int,
    holderName: String,
    issuedAt: Date,
    code: String,
    signature: Data
  ) -> String {
    let formatter = ISO8601DateFormatter()
    return """
  Tathmfy Verified Credit Score
  Holder: \(holderName)
  Score: \(score)
  Issued: \(formatter.string(from: issuedAt))
  Verification: \(code)
  Signature: \(signature.base64EncodedString())
  Verify at tathmfy.com/verify
  """
  }

  private static func canonicalPayload(
    score: Int,
    holderName: String,
    issuedAt: Date,
    code: String
  ) -> String {
    let formatter = ISO8601DateFormatter()
    return "\(score)|\(holderName)|\(formatter.string(from: issuedAt))|\(code)"
  }

  private static func sign(
    score: Int,
    holderName: String,
    issuedAt: Date,
    code: String
  ) throws -> Data {
    let key = try loadOrCreateSigningKey()
    let data = Data(canonicalPayload(score: score, holderName: holderName, issuedAt: issuedAt, code: code).utf8)
    let signature = try key.signature(for: data)
    return signature.rawRepresentation
  }

  private static func loadOrCreateSigningKey() throws -> P256.Signing.PrivateKey {
    if let stored = UserDefaults.standard.data(forKey: signingKeyUserDefaultsKey) {
      return try P256.Signing.PrivateKey(rawRepresentation: stored)
    }
    let key = P256.Signing.PrivateKey()
    UserDefaults.standard.set(key.rawRepresentation, forKey: signingKeyUserDefaultsKey)
    return key
  }

  private static func generateVerificationCode() -> String {
    let digits = String(format: "%03d", Int.random(in: 0 ... 999))
    let suffix = String((0 ..< 4).map { _ in "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".randomElement()! })
    return "TMN-\(digits)-\(suffix)"
  }
}
