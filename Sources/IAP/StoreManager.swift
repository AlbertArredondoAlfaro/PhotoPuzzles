import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class StoreManager {
    // Replace with your App Store Connect product identifiers.
    private let productIDs: Set<String> = [
        "photopuzzle.remove_ads_unlimited",
        "photopuzzle.theme_pack_basic"
    ]

    var products: [Product] = []
    var purchasedIDs: Set<String> = []

    var isAdsRemoved: Bool {
        purchasedIDs.contains("photopuzzle.remove_ads_unlimited")
    }

    var hasUnlimited: Bool {
        purchasedIDs.contains("photopuzzle.remove_ads_unlimited")
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Array(productIDs))
        } catch {
            products = []
        }
        await updatePurchasedProducts()
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchasedProducts()
                    return true
                case .unverified:
                    return false
                }
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            return
        }
        await updatePurchasedProducts()
    }

    func updatePurchasedProducts() async {
        var updated: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                updated.insert(transaction.productID)
            }
        }
        purchasedIDs = updated
    }
}
