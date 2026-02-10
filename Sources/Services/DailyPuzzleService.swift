import Foundation
import UIKit

enum DailyPuzzleService {
    static func loadImages() -> [DailyImage] {
        guard let url = Bundle.main.url(forResource: "daily", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let images = try? JSONDecoder().decode([DailyImage].self, from: data) else {
            return []
        }
        return images
    }

    static func dailyImage() -> DailyImage? {
        let images = loadImages()
        guard !images.isEmpty else { return nil }
        // Stable daily index based on day count to keep the same image for everyone each day.
        let days = daysSinceReference()
        let index = days % images.count
        return images[index]
    }

    static func imageForDaily(_ daily: DailyImage) -> UIImage? {
        if let url = Bundle.main.url(forResource: daily.name, withExtension: "png", subdirectory: "DailyImages") {
            return UIImage(contentsOfFile: url.path)
        }
        return UIImage(named: daily.name)
    }

    private static func daysSinceReference() -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let reference = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? Date(timeIntervalSince1970: 0)
        let diff = calendar.dateComponents([.day], from: reference, to: start)
        return diff.day ?? 0
    }
}
