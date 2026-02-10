import Foundation

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }

    var displayKey: String {
        switch self {
        case .easy: return "difficulty_easy"
        case .medium: return "difficulty_medium"
        case .hard: return "difficulty_hard"
        }
    }
}
