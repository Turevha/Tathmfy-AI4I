# On-device intelligence

Tathmfy uses on-device AI for **capture** and **language** tasks. The **credit score** is a separate, explainable engine (see [../docs/SCORING_ENGINE.md](../docs/SCORING_ENGINE.md)).

## Live today — Apple Foundation Models

`ChatAssistantService.swift` checks `SystemLanguageModel.default.availability` on supported OS versions and streams responses via `LanguageModelSession`. The assistant is instructed to:

- Answer only from the user’s financial snapshot
- Never claim data it does not have
- Avoid mentioning cloud or servers

If Foundation Models errors at runtime, the service falls back to `LocalChatAssistant`.

## Designated fallback — Gemma 3 1B (quantised)

**Status:** Documented edge strategy for devices without Foundation Models. Not shipped as a separate quantised runtime in the current app binary.

**Design targets** (engineering goals for a future quantised bundle):

| Target | Rationale |
|--------|-----------|
| < 256 MB RAM | Run on mid-tier phones common in target markets |
| < 100 ms per inference | Keep chat responsive offline |

Design targets are engineering goals. Performance figures will be published only after on-device validation on representative hardware.

## Why not cloud inference?

Cloud LLM inference would require uploading financial context — incompatible with the privacy architecture and Data Protection Act posture.

## Vision and Natural Language (capture lane)

Receipt and mobile-money statement capture uses on-device Vision OCR plus categorisation helpers. Extracted fields are **always editable** before save.

## Further reading

- [gemma-fallback-design.md](gemma-fallback-design.md) — integration outline without fabricated code
- [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) — full system diagram
