import UIKit

struct GameConfig: Identifiable {
    let id = UUID()
    let image: UIImage
    let difficulty: Difficulty
    let filter: ImageFilter
    let isDaily: Bool
    let dailyInfo: DailyImage?
}
