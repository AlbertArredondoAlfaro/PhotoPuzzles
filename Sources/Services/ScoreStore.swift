import Foundation

enum ScoreStore {
    private static func timeKey(_ difficulty: Difficulty) -> String { "score.bestTime.\(difficulty.rawValue)" }
    private static func movesKey(_ difficulty: Difficulty) -> String { "score.bestMoves.\(difficulty.rawValue)" }

    static func bestTime(for difficulty: Difficulty) -> TimeInterval? {
        let value = UserDefaults.standard.double(forKey: timeKey(difficulty))
        return value > 0 ? value : nil
    }

    static func bestMoves(for difficulty: Difficulty) -> Int? {
        let value = UserDefaults.standard.integer(forKey: movesKey(difficulty))
        return value > 0 ? value : nil
    }

    static func record(result: GameResult) {
        let defaults = UserDefaults.standard
        let bestTime = bestTime(for: result.difficulty)
        let bestMoves = bestMoves(for: result.difficulty)

        if bestTime == nil || result.elapsed < bestTime! {
            defaults.set(result.elapsed, forKey: timeKey(result.difficulty))
        }
        if bestMoves == nil || result.moves < bestMoves! {
            defaults.set(result.moves, forKey: movesKey(result.difficulty))
        }
    }
}
