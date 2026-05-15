import Foundation

final class ShareManager {
    static let shared = ShareManager()
    
    private init() {}
    
    func share(text: String, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
    
    func share(image: UIImage, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
    
    func share(url: URL, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
    
    func share(file: URL, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
    
    func shareMultiple(_ items: [Any], from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
}

import UIKit