import Foundation
import Observation

@MainActor
@Observable
final class UserSettings {
    private enum Keys {
        static let difficulty = "settings.difficulty"
        static let filter = "settings.filter"
        static let playsToday = "limits.playsToday"
        static let bonusPlays = "limits.bonusPlays"
        static let lastPlayDay = "limits.lastPlayDay"
    }

    var difficulty: Difficulty {
        didSet { UserDefaults.standard.set(difficulty.rawValue, forKey: Keys.difficulty) }
    }

    var filter: ImageFilter {
        didSet { UserDefaults.standard.set(filter.rawValue, forKey: Keys.filter) }
    }

    // Free daily limit before ads or IAP unlocks.
    var dailyLimit: Int = 3
    var playsToday: Int {
        didSet { UserDefaults.standard.set(playsToday, forKey: Keys.playsToday) }
    }

    var bonusPlays: Int {
        didSet { UserDefaults.standard.set(bonusPlays, forKey: Keys.bonusPlays) }
    }

    private var lastPlayDay: Date {
        didSet { UserDefaults.standard.set(lastPlayDay, forKey: Keys.lastPlayDay) }
    }

    init() {
        let defaults = UserDefaults.standard
        let diffRaw = defaults.string(forKey: Keys.difficulty)
        let filterRaw = defaults.string(forKey: Keys.filter)
        difficulty = Difficulty(rawValue: diffRaw ?? "") ?? .easy
        filter = ImageFilter(rawValue: filterRaw ?? "") ?? .none
        playsToday = defaults.integer(forKey: Keys.playsToday)
        bonusPlays = defaults.integer(forKey: Keys.bonusPlays)
        lastPlayDay = defaults.object(forKey: Keys.lastPlayDay) as? Date ?? Calendar.current.startOfDay(for: Date())
        resetIfNewDay()
    }

    func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        if today != lastPlayDay {
            playsToday = 0
            bonusPlays = 0
            lastPlayDay = today
        }
    }

    func canStartPuzzle(isUnlimited: Bool) -> Bool {
        resetIfNewDay()
        if isUnlimited { return true }
        return playsToday < dailyLimit || bonusPlays > 0
    }

    func registerPuzzleStart(isUnlimited: Bool) {
        resetIfNewDay()
        if isUnlimited { return }
        if playsToday < dailyLimit {
            playsToday += 1
        } else if bonusPlays > 0 {
            bonusPlays -= 1
            playsToday += 1
        }
    }

    func addBonusPlay() {
        resetIfNewDay()
        bonusPlays += 1
    }
}
