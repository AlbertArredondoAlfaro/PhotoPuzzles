import Foundation

enum TimeFormatter {
    static func clockString(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let secondsText = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(minutes):\(secondsText)"
    }
}
