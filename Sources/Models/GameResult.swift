import Foundation

struct GameResult: Hashable {
    let difficulty: Difficulty
    let moves: Int
    let elapsed: TimeInterval
}
