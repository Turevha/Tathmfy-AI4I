# Tathmfy

On-device AI credit identity for Africa's informal economy. The borrower builds a verifiable score on their phone; lenders check a signed credential in the browser — never the raw ledger.

**Live:** https://tathmfy.com · **Verify:** https://tathmfy.com/verify

---

## Documentation

Start at **[REVIEW.md](REVIEW.md)** → **[ai4i-submission/README.md](ai4i-submission/README.md)**

Supporting PDFs (business model, deployment plan, architecture note, risk checklist, testing pack) are linked from the proposal cover.

---

## Repository structure

```
Tathmfy/              Native mobile app (SwiftUI, TCA, SwiftData)
TathmfyTests/         Unit tests — score engine, dial geometry, OCR
Tathmfy.xcodeproj     Xcode project
web/                  Marketing site + lender verify portal
ai4i-submission/      Architecture and technical documentation
assets/               Brand assets and reference screens
Scripts/              Build utilities
```

---

## Product

1. **Log** — manual entry or camera scan (Vision OCR) of receipts and mobile-money statements
2. **Score + Insights** — 300–850 dial, factor breakdown, improvement actions
3. **Share** — cryptographically signed credential with verification code
4. **Chat** — on-device assistant (Apple Foundation Models on supported devices)

Scoring runs entirely on-device. The only server call is lender credential verification.

---

## Scoring engine

| Factor | Weight | Activates |
|--------|--------|-----------|
| Payment consistency | 35% | Day 60 |
| Income stability | 25% | Day 90 |
| Spending discipline | 20% | Day 0 |
| Data depth | 15% | Day 0 |
| Data verification | 5% | Day 0 |

Real score requires 30+ days and at least one verified entry. See `Tathmfy/Core/Scoring/`.

---

## Run tests

```bash
xcodebuild test -scheme Tathmfy -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Web

Static site and verify portal in `web/`. Deployed on Vercel; verify backend on Supabase (credential metadata only).

---

## Team

- **Trevor Macheka** — Lead innovator, data engineering
- **Wendy Chigu** — Finance & mathematics; credit-risk and unit economics

---

## Contact

https://tathmfy.com
