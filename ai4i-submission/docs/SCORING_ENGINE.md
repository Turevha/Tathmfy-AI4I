# Scoring engine

Deterministic, explainable weighted-factor model — **not** a neural network. Outputs a **300–850** range lenders already understand.

Source: `Tathmfy/Core/Scoring/ScoreEngine.swift`, `ScoreFactor.swift`

## Factors

| Factor | Weight | Activation |
|--------|--------|------------|
| Payment consistency | 35% | Day 60 |
| Income stability | 25% | Day 90 |
| Spending discipline | 20% | Day 0 |
| Data depth | 15% | Day 0 |
| Data verification | 5% | Day 0 |

## Real score gate

Indicative until **30+ days** and **≥1 verified entry** (scanned + confirmed document).

## Tiers

Building 300–579 · Fair 580–669 · Good 670–739 · Strong 740–799 · Excellent 800–850

## Tests

`TathmfyTests/TathmfyTests.swift` — `ScoreEngineTests` suite.
