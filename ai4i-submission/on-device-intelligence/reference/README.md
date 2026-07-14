# On-device language model — reference code

These Swift files are a **readable reference implementation** for reviewers. They mirror the production routing in `Tathmfy/Core/Chat/ChatAssistantService.swift` but are **not compiled into the app target** — the shipping binary uses Foundation Models where available and `LocalChatAssistant` otherwise.

## Files

| File | Purpose |
|------|---------|
| `OnDeviceLanguageModelProviding.swift` | Shared streaming protocol |
| `FinancialPromptBuilder.swift` | Grounded prompt assembly from the user's snapshot |
| `FoundationModelsChatProvider.swift` | Live Apple Foundation Models path (mirrors production) |
| `Gemma3QuantizedEngine.swift` | Quantised Gemma 3 1B fallback — structure + load lifecycle; weights not bundled in repo |
| `LanguageModelRouter.swift` | Selection order: Foundation Models → Gemma → local rules assistant |

## What is live vs planned

| Path | Status in production app |
|------|--------------------------|
| Apple Foundation Models | **Live** on supported OS versions |
| Gemma 3 1B quantised | **Planned** — this reference shows how it slots in |
| Local rules assistant | **Live** fallback today when Foundation Models unavailable |
| Credit score engine | **Always deterministic** — never uses an LLM |

## Design targets (not benchmark results)

Engineering goals for the Gemma bundle are documented as constants in `Gemma3QuantizedEngine.swift`. They are **targets to validate on device**, not measured numbers in this repository.
