import CoreText
import Foundation

enum FontRegistration {
  private static let registration: Void = {
    registerBundledFontsOnce()
  }()

  static func registerBundledFonts() {
    _ = registration
  }

  private static func registerBundledFontsOnce() {
    let fontNames = [
      "BricolageGrotesque-Variable",
      "HankenGrotesk-Variable",
      "InstrumentSerif-Italic",
    ]

    for name in fontNames {
      guard let url = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
        ?? Bundle.main.url(forResource: name, withExtension: "ttf") else {
        continue
      }
      var error: Unmanaged<CFError>?
      CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
    }
  }
}
