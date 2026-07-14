# On-device intelligence

Tathmfy uses on-device AI for **capture** and **language** tasks. The **credit score** is a separate, explainable engine (see [../docs/SCORING_ENGINE.md](../docs/SCORING_ENGINE.md)).

## Live today — Apple Foundation Models

`ChatAssistantService.swift` checks `SystemLanguageModel.default.availability` on supported OS versions and streams responses via `LanguageModelSession`. The assistant is instructed to:

- Answer only from the user’s financial snapshot
- Never claim data it does not have
- Avoid mentioning cloud or servers

If Foundation Models errors at runtime, the service falls back to `LocalChatAssistant`.

## Designated fallback — Gemma 3 1B (quantised)

**Status:** Reference implementation in [`reference/Gemma3QuantizedEngine.swift`](reference/Gemma3QuantizedEngine.swift). Quantised weights are **not** bundled in this repository; production uses `LocalChatAssistant` until the Gemma asset ships.

**Design targets** (engineering goals — validate on device before publishing):

| Target | Rationale |
|--------|-----------|
| < 256 MB RAM | Run on mid-tier phones common in target markets |
| < 100 ms per token step | Keep chat responsive offline |

See also [`FOUNDATION_MODELS.md`](FOUNDATION_MODELS.md) for the live Apple path.

## Reference code (for reviewers)

| File | Purpose |
|------|---------|
| [`reference/README.md`](reference/README.md) | How to read the reference layer |
| [`reference/FoundationModelsChatProvider.swift`](reference/FoundationModelsChatProvider.swift) | Mirrors live Foundation Models integration |
| [`reference/Gemma3QuantizedEngine.swift`](reference/Gemma3QuantizedEngine.swift) | Gemma load lifecycle + streaming shape |
| [`reference/LanguageModelRouter.swift`](reference/LanguageModelRouter.swift) | Provider selection order |

## Why not cloud inference?

Cloud LLM inference would require uploading financial context — incompatible with the privacy architecture and Data Protection Act posture.

## Vision and Natural Language (capture lane)

Receipt and mobile-money statement capture uses on-device Vision OCR plus categorisation helpers. Extracted fields are **always editable** before save.

## Further reading

- [FOUNDATION_MODELS.md](FOUNDATION_MODELS.md) — live Apple integration in the app
- [reference/Gemma3QuantizedEngine.swift](reference/Gemma3QuantizedEngine.swift) — quantised fallback reference code
- [gemma-fallback-design.md](gemma-fallback-design.md) — integration outline
- [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) — full system diagram
