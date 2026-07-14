# Tathmfy — technical review guide

**AI4I 2026 · Track 3 Development · Financial Services & Fintech**

## Start here

1. **[ai4i-submission/README.md](ai4i-submission/README.md)** — documentation map and technical summary
2. **Live verification** — https://tathmfy.com/verify
3. **Proposal & one-pagers** — linked on the proposal cover

## Repository contents

| Area | Path |
|------|------|
| Mobile app | `Tathmfy/` |
| Unit tests | `TathmfyTests/` |
| Verify portal | `web/verify/` |
| Architecture | `ai4i-submission/docs/` |
| On-device AI | `ai4i-submission/on-device-intelligence/` |

## Key facts

- Score range **300–850** with five explainable weighted factors
- No personal financial records stored on our servers
- Credentials signed on-device (Secure Enclave / CryptoKit)
- Zimbabwe pilot 2026, then Southern Africa

## Run tests

```bash
xcodebuild test -scheme Tathmfy -destination 'platform=iOS Simulator,name=iPhone 16'
```
