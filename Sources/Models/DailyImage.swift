import Foundation

struct DailyImage: Identifiable, Codable, Hashable {
    let name: String
    let title: String
    let author: String
    let source: String

    var id: String { name }
}
