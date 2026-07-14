# System architecture

Tathmfy is a native mobile app paired with a lightweight web verification layer. **Everything sensitive stays on the borrower's device.** The only server interaction is a lender validating a signed credential.

## Trust boundary

```
┌─────────────────────────────────────────────────────────────┐
│  BORROWER DEVICE                                            │
│  Log UI → Capture (manual + Vision OCR) → SwiftData         │
│       → Explainable score engine → Secure Enclave signing   │
│  Chat: Foundation Models (primary) → local fallback         │
└──────────────────────────┬──────────────────────────────────┘
                           │  signed credential only
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  VERIFY LAYER                                               │
│  Vercel (tathmfy.com/verify) → Supabase (metadata only)     │
└─────────────────────────────────────────────────────────────┘
```

## Mobile app (`Tathmfy/`)

| Layer | Role |
|-------|------|
| `Features/` | Home, Score, Log, Share, Chat |
| `Core/Scoring/` | `ScoreEngine`, factor activation, tiers |
| `Core/Repositories/` | SwiftData, OCR pipeline |
| `Core/Chat/` | `ChatAssistantService` → Foundation Models or fallback |

## Web (`web/`)

| Path | Role |
|------|------|
| `/` | Marketing |
| `/verify` | Lender credential validation (live) |

## What never leaves the device

Raw entries, categories, amounts, OCR images, chat content.

## What may cross (borrower-initiated)

Verification code, score, tier, factor grades, issue/expiry, chosen identity fields.

## Compute strategy

Production scoring is edge-first. ZCHPC CCE is proposed for batch validation, synthetic data generation, and verify load testing — not per-user cloud inference.
