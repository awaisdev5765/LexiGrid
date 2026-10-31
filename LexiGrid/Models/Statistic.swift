import Foundation

struct Statistic: Codable {
    var frequencies = [Int](repeating: 0, count: 6)
    var games = 0
    var streak = 0
    var maxStreak = 0
    var totalWinningGuesses = 0
    var totalHintsUsed = 0
    var bestScore = 0

    var wins: Int { frequencies.reduce(0, +) }
    var averageWinningGuesses: Double {
        wins == 0 ? 0 : Double(totalWinningGuesses) / Double(wins)
    }

    private enum CodingKeys: String, CodingKey {
        case frequencies, games, streak, maxStreak, totalWinningGuesses, totalHintsUsed, bestScore
    }

    init() {}

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        frequencies = try values.decodeIfPresent([Int].self, forKey: .frequencies) ?? [Int](repeating: 0, count: 6)
        games = try values.decodeIfPresent(Int.self, forKey: .games) ?? 0
        streak = try values.decodeIfPresent(Int.self, forKey: .streak) ?? 0
        maxStreak = try values.decodeIfPresent(Int.self, forKey: .maxStreak) ?? 0
        totalWinningGuesses = try values.decodeIfPresent(Int.self, forKey: .totalWinningGuesses)
            ?? frequencies.enumerated().reduce(0) { $0 + ($1.offset + 1) * $1.element }
        totalHintsUsed = try values.decodeIfPresent(Int.self, forKey: .totalHintsUsed) ?? 0
        bestScore = try values.decodeIfPresent(Int.self, forKey: .bestScore) ?? 0
    }

    func saveStat() { NSUbiquitousKeyValueStore.stat = self }
    static func loadStat() -> Statistic { NSUbiquitousKeyValueStore.stat }

    mutating func update(win: Bool, index: Int? = nil, hintsUsed: Int = 0, score: Int = 0) {
        games += 1
        totalHintsUsed += hintsUsed
        streak = win ? streak + 1 : 0
        if win, let index = index {
            frequencies[index] += 1
            totalWinningGuesses += index + 1
            maxStreak = max(maxStreak, streak)
            bestScore = max(bestScore, score)
        }
        saveStat()
    }
}
