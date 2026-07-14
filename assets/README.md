# Tathmfy — Asset Pack

Production-ready and reference assets for the mobile app build. See `../README.md` for the product spec.

## app-icon/
iOS app-icon PNGs at every required size + a `Contents.json` ready to drop into Xcode.
- **To use:** create `Assets.xcassets/AppIcon.appiconset/`, copy every `icon-*.png` and `Contents.json` into it. `icon-1024.png` is the App Store marketing icon.
- The mark is the score arc on a radial espresso ground; corners are pre-rounded (iOS also masks them).

## logo/
- `mark-512/256/128/96/64.png` — logo mark only, **transparent background**, bone dot (for dark surfaces).
- `mark-*-ink.png` — same mark with an espresso dot (for light surfaces).
- `wordmark-lockup.png` — icon + "Tathmfy" wordmark lockup (Bricolage Grotesque).
- *Vector source of truth:* the arc is 220° from 160°, gradient `#D9663F → #E5A93E → #2E8676`. Rebuild as SwiftUI `Shape` for crisp scaling (see ../README §4).

## components/
- `score-dial-712/820/480.png` — the hero dial rendered at three scores (Good / Excellent / Building tiers). Reference for the SwiftUI component; do not ship the PNGs — build the dial natively and animated.

## screens/
All 10 screens at 393×852 (1× point size), device-framed:
`01-onboarding`, `02-sign-in`, `03-home-day1`, `04-home-active`, `05-log-manual`, `06-log-camera`, `07-score-insights`, `08-share-certificate`, `09-chat`, `10-states`.
These are **visual references** to recreate natively — not shipped assets.

## color-tokens.png
Visual swatch sheet of the palette. Authoritative hex values + token names + usage are in `../README.md` §3.2. Create one Color Set per token in `Assets.xcassets` (suggested names match the README table: `clay`, `espresso`, `jewelTeal`, `gold`, `bone`, etc.).

## Fonts (not bundled — license yourself)
- **Bricolage Grotesque** (display + numerals) — SIL OFL, free: fonts.google.com/specimen/Bricolage+Grotesque
- **Hanken Grotesk** (UI/body) — SIL OFL, free: fonts.google.com/specimen/Hanken+Grotesk
- **Instrument Serif** (italic accents) — SIL OFL, free: fonts.google.com/specimen/Instrument+Serif
Add the `.ttf`s to the target, register in Info.plist (`UIAppFonts`), load via SwiftUI `Font.custom`. Fallbacks: SF Pro Rounded / SF Pro Text.

## Not included (build natively)
WidgetKit widget renders, animated dial states, and any haptic/transition assets — these are code, described in `../README.md`.
