import Foundation

enum AdConfig {
    static func value(for key: String) -> String {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let value = plist[key] as? String else {
            return ""
        }
        return value
    }

    static var bannerUnitID: String { value(for: "BannerAdUnitID") }
    static var interstitialUnitID: String { value(for: "InterstitialAdUnitID") }
    static var rewardedUnitID: String { value(for: "RewardedAdUnitID") }
}
