import Foundation

final class InAppPurchaseManager {
    static let shared = InAppPurchaseManager()
    
    private init() {}
    
    enum Product: String {
        case premium = "com.ninehoto.premium"
        case pro = "com.ninehoto.pro"
    }
    
    var isPremium: Bool {
        UserDefaults.standard.bool(forKey: "is_premium")
    }
    
    func purchase(_ product: Product) async -> Bool {
        // In a real app, this would use StoreKit
        // For demo, just set premium to true
        UserDefaults.standard.set(true, forKey: "is_premium")
        return true
    }
    
    func restorePurchases() async -> Bool {
        // In a real app, this would restore purchases
        return true
    }
}