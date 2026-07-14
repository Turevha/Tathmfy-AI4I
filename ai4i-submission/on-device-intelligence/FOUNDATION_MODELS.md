# Apple Foundation Models — production integration

## Where it lives

| File | Role |
|------|------|
| `Tathmfy/Core/Chat/ChatAssistantService.swift` | Routes chat requests |
| `Tathmfy/Core/Chat/ChatFinancialContext.swift` | Builds grounded on-device snapshot |
| `Tathmfy/Core/Chat/LocalChatAssistant.swift` | Offline rules fallback (live today) |

Reference mirror: [`reference/FoundationModelsChatProvider.swift`](reference/FoundationModelsChatProvider.swift)

## Routing (live)

```
User prompt
    │
    ▼
ChatFinancialContext.load()     ← SwiftData entries + score summary, stays on device
    │
    ▼
SystemLanguageModel.available?  ← Apple Foundation Models framework
    │ yes                          │ no
    ▼                              ▼
LanguageModelSession          LocalChatAssistant
(streaming tokens)            (grounded template replies)
```

## Grounding rules (production system prompt)

The assistant is instructed to:

- Answer in 2–4 concise sentences
- Use only the user's financial snapshot
- Never invent transactions or scores
- Never mention cloud, servers, or the internet

If Foundation Models throws at runtime, production code falls back to `LocalChatAssistant` inside the same request.

## Relationship to scoring

The language stack **does not** compute the credit score. `ScoreEngine` is a deterministic weighted-factor model in `Tathmfy/Core/Scoring/`. Chat reads score outputs; it never writes them.

## Relationship to Gemma fallback

See [`reference/Gemma3QuantizedEngine.swift`](reference/Gemma3QuantizedEngine.swift) for how a quantised Gemma 3 1B bundle would slot between Foundation Models and the rules assistant. Weights are not committed in this repository.
