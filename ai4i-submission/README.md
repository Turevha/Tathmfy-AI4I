# Tathmfy — technical documentation

Architecture, scoring, privacy, testing, and on-device AI notes for the Tathmfy platform.

## Live demos

| Resource | URL |
|----------|-----|
| Marketing site | https://tathmfy.com |
| Lender verification | https://tathmfy.com/verify |

## Documentation

| Topic | File |
|-------|------|
| Architecture & trust boundary | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Scoring engine | [docs/SCORING_ENGINE.md](docs/SCORING_ENGINE.md) |
| Verification & privacy | [docs/VERIFY_AND_PRIVACY.md](docs/VERIFY_AND_PRIVACY.md) |
| Testing & validation | [docs/TESTING.md](docs/TESTING.md) |
| On-device language models | [on-device-intelligence/README.md](on-device-intelligence/README.md) · [FOUNDATION_MODELS.md](on-device-intelligence/FOUNDATION_MODELS.md) · [reference code](on-device-intelligence/reference/) |

## Repository layout

```
Tathmfy/              Mobile app source
TathmfyTests/         Unit tests
web/                  Site + verify portal
ai4i-submission/      This documentation
```

## Technical summary

- **300–850** score · weights 35 / 25 / 20 / 15 / 5 %
- Scoring on-device; no server-side transaction ledger
- **Apple Foundation Models** on supported devices; **Gemma 3 1B** as designated edge fallback (design targets)
- **CryptoKit + Secure Enclave** credential signing
- **Supabase** verify store — credential metadata only

## Tests

```bash
xcodebuild test -scheme Tathmfy -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Team

- **Trevor Macheka** — Lead innovator, data engineering
- **Wendy Chigu** — Finance & mathematics; credit-risk and unit economics
