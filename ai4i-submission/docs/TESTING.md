# Testing and validation

## Unit tests

Target: `TathmfyTests/TathmfyTests.swift`

| Suite | Coverage |
|-------|----------|
| `ScoreDialGeometryTests` | 220° arc, 300–850 mapping, progress dial |
| `ScoreEngineTests` | Indicative gating, activation days, weights |
| `StatementOCRServiceTests` | OCR parsing fixtures |

```bash
xcodebuild test -scheme Tathmfy -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Roadmap

- Certificate signing validation tests
- Extended synthetic archetype replay
- Fairness checks across income profiles

## Synthetic data

Programmatic informal-income archetypes; KS and Pearson validation before use. No scraped or purchased PII.

## Honest limits

- No published OCR accuracy percentages for all statement layouts
- No measured Gemma benchmarks in this repo
- Pilot outcome metrics — collected during the pilot phase
