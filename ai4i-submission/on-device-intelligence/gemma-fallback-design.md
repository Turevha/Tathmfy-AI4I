# Gemma 3 1B fallback — design outline

This note describes how a quantised Gemma 3 1B bundle would fit the Tathmfy architecture **without claiming it is already benchmarked or live in production**.

## Role

| Component | Primary | Fallback |
|-----------|---------|----------|
| On-device chat | Apple Foundation Models | Gemma 3 1B quantised (planned) |
| Credit score | Explainable factor engine | N/A — no LLM |
| OCR / capture | Vision + NL frameworks | Manual entry |

The scoring path **never** depends on a language model.

## Integration sketch

1. `ChatAssistantService` already branches to `LocalChatAssistant` when Foundation Models is unavailable.
2. A future `GemmaChatProvider` would implement the same `AsyncThrowingStream<String, Error>` interface.
3. Model weights ship as an optional on-demand asset (App Store size and regional bandwidth considered).
4. Quantisation: 4-bit or 8-bit GGUF / MLX — final choice after on-device profiling.

## Design targets (not measurements)

- **Memory:** < 256 MB resident during inference
- **Latency:** < 100 ms median token generation step on a reference mid-tier device

Targets will be validated on hardware representative of Zimbabwean and regional deployment before any public performance claim.

## Licence

Gemma weights are subject to [Google’s Gemma terms of use](https://ai.google.dev/gemma/terms). Apple frameworks follow platform licences.

## What this document is not

- Not a benchmark report
- Not a promise that Gemma is running in the current production build
- Not a substitute for the live Foundation Models path on supported devices

Foundation Models is live on supported devices. Gemma 3 1B is the planned edge fallback. The scoring engine is deterministic throughout.
