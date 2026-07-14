import XCTest
@testable import Tathmfy

final class ScoreDialGeometryTests: XCTestCase {
  func testTrackArcSpans220Degrees() {
    let span = ScoreDialGeometry.trackEndDegrees - ScoreDialGeometry.trackStartDegrees
    XCTAssertEqual(span, 220, accuracy: 0.001)
  }

  func testTrackStartsAt160DegreesFromTop() {
    XCTAssertEqual(ScoreDialGeometry.trackStartDegrees, 70, accuracy: 0.001)
  }

  func testScoreFractionAtBounds() {
    XCTAssertEqual(ScoreDialGeometry.scoreFraction(300), 0, accuracy: 0.001)
    XCTAssertEqual(ScoreDialGeometry.scoreFraction(850), 1, accuracy: 0.001)
  }

  func testScoreFractionClampsOutOfRange() {
    XCTAssertEqual(ScoreDialGeometry.scoreFraction(100), 0, accuracy: 0.001)
    XCTAssertEqual(ScoreDialGeometry.scoreFraction(900), 1, accuracy: 0.001)
  }

  func testScore712Fraction() {
    // (712 - 300) / 550 ≈ 0.749
    XCTAssertEqual(ScoreDialGeometry.scoreFraction(712), 412.0 / 550.0, accuracy: 0.001)
  }

  func testValueEndDegreesAtMinAndMaxScore() {
    XCTAssertEqual(
      ScoreDialGeometry.valueEndDegrees(score: 300),
      ScoreDialGeometry.trackStartDegrees,
      accuracy: 0.001
    )
    XCTAssertEqual(
      ScoreDialGeometry.valueEndDegrees(score: 850),
      ScoreDialGeometry.trackEndDegrees,
      accuracy: 0.001
    )
  }

  func testProgressFraction() {
    XCTAssertEqual(ScoreDialGeometry.progressFraction(currentDay: 1, totalDays: 30), 1.0 / 30.0, accuracy: 0.001)
    XCTAssertEqual(ScoreDialGeometry.progressFraction(currentDay: 30, totalDays: 30), 1, accuracy: 0.001)
    XCTAssertEqual(ScoreDialGeometry.progressFraction(currentDay: 0, totalDays: 30), 0, accuracy: 0.001)
  }

  func testStrokeAndKnobSizing() {
    let diameter: CGFloat = 200
    let stroke = ScoreDialGeometry.strokeWidth(diameter: diameter)
    XCTAssertEqual(stroke, 15, accuracy: 0.001)
    XCTAssertEqual(ScoreDialGeometry.knobDiameter(strokeWidth: stroke), stroke * 1.2, accuracy: 0.001)
  }

  func testPointOnArcAtEast() {
    let center = CGPoint(x: 100, y: 100)
    let point = ScoreDialGeometry.pointOnArc(center: center, radius: 50, degreesFromEast: 0)
    XCTAssertEqual(point.x, 150, accuracy: 0.001)
    XCTAssertEqual(point.y, 100, accuracy: 0.001)
  }

  func testScoreDialModeTargetFraction() {
    XCTAssertEqual(ScoreDialMode.score(712).targetFraction, ScoreDialGeometry.scoreFraction(712), accuracy: 0.001)
    XCTAssertEqual(
      ScoreDialMode.progress(currentDay: 1, totalDays: 30).targetFraction,
      1.0 / 30.0,
      accuracy: 0.001
    )
  }
}

final class ScoreEngineTests: XCTestCase {
  func testIndicativeScoreBefore30Days() {
    let input = ScoreEngineInput(
      joinDate: .now,
      entries: [],
      verifiedSourceCount: 0,
      now: .now
    )
    XCTAssertFalse(ScoreEngine.hasRealScore(input: input))
    XCTAssertEqual(ScoreEngine.computeScore(input: input), 640)
  }

  func testRealScoreRequiresVerifiedSource() {
    let joinDate = Calendar.current.date(byAdding: .day, value: -40, to: .now)!
    let inputWithoutVerified = ScoreEngineInput(
      joinDate: joinDate,
      entries: [
        .init(type: .income, amount: 100, category: "Wages", date: .now, verified: false),
      ],
      verifiedSourceCount: 0,
      now: .now
    )
    XCTAssertFalse(ScoreEngine.hasRealScore(input: inputWithoutVerified))

    let inputWithVerified = ScoreEngineInput(
      joinDate: joinDate,
      entries: [
        .init(type: .income, amount: 100, category: "Wages", date: .now, verified: true),
      ],
      verifiedSourceCount: 1,
      now: .now
    )
    XCTAssertTrue(ScoreEngine.hasRealScore(input: inputWithVerified))
  }

  func testScoreWithinRange() {
    let joinDate = Calendar.current.date(byAdding: .day, value: -120, to: .now)!
    let entries = DemoData.entries.map { draft in
      ScoreEngineInput.EntrySnapshot(
        type: draft.type,
        amount: draft.amount,
        category: draft.category,
        date: Calendar.current.date(byAdding: .day, value: -draft.daysAgo, to: .now) ?? .now,
        verified: draft.verified
      )
    }
    let score = ScoreEngine.computeScore(
      input: ScoreEngineInput(joinDate: joinDate, entries: entries, verifiedSourceCount: 1, now: .now)
    )
    XCTAssertGreaterThanOrEqual(score, 300)
    XCTAssertLessThanOrEqual(score, 850)
  }
}

final class TathmfyTests: XCTestCase {
  func testScoreTierMapping() {
    XCTAssertEqual(ScoreTier.tier(for: 400), .building)
    XCTAssertEqual(ScoreTier.tier(for: 620), .fair)
    XCTAssertEqual(ScoreTier.tier(for: 712), .good)
    XCTAssertEqual(ScoreTier.tier(for: 760), .strong)
    XCTAssertEqual(ScoreTier.tier(for: 820), .excellent)
  }
}

final class StatementOCRServiceTests: XCTestCase {
  func testParseStatementLinesExtractsIncomeAndExpense() {
    let lines = [
      "M-PESA STATEMENT",
      "12 Jun · Sale +340.00",
      "14 Jun · Rent -200.00",
      "18 Jun · Sale +275.00",
    ]

    let entries = StatementOCRService.parseStatementLines(lines)

    XCTAssertEqual(entries.count, 3)
    XCTAssertEqual(entries[0].name, "12 Jun · Sale")
    XCTAssertEqual(entries[0].amount, 340)
    XCTAssertTrue(entries[0].isIncome)
    XCTAssertEqual(entries[1].amount, 200)
    XCTAssertFalse(entries[1].isIncome)
  }

  func testParseStatementLinesReturnsEmptyForUnrecognizedText() {
    XCTAssertTrue(StatementOCRService.parseStatementLines(["Hello world"]).isEmpty)
  }
}
