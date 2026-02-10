import Foundation
import Observation
import GoogleMobileAds
import UIKit

@MainActor
@Observable
final class AdMobManager: NSObject {
    private(set) var interstitial: GADInterstitialAd?
    private(set) var rewarded: GADRewardedAd?

    func start() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        loadInterstitial()
        loadRewarded()
    }

    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AdConfig.interstitialUnitID, request: request) { [weak self] ad, error in
            if let _ = error {
                self?.interstitial = nil
                return
            }
            self?.interstitial = ad
        }
    }

    func loadRewarded() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: AdConfig.rewardedUnitID, request: request) { [weak self] ad, error in
            if let _ = error {
                self?.rewarded = nil
                return
            }
            self?.rewarded = ad
        }
    }

    func showInterstitial() {
        guard let root = UIApplication.shared.topViewController(), let ad = interstitial else { return }
        ad.present(fromRootViewController: root)
        interstitial = nil
        loadInterstitial()
    }

    func showRewarded(onReward: @escaping () -> Void) {
        guard let root = UIApplication.shared.topViewController(), let ad = rewarded else { return }
        ad.present(fromRootViewController: root) {
            onReward()
        }
        rewarded = nil
        loadRewarded()
    }
}

extension UIApplication {
    func topViewController() -> UIViewController? {
        guard let scene = connectedScenes.first as? UIWindowScene else { return nil }
        guard let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        return root.topMostViewController()
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
