import Foundation

final class ClipboardManager {
    static let shared = ClipboardManager()
    
    private init() {}
    
    func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    func copyImage(_ image: UIImage) {
        UIPasteboard.general.image = image
    }
    
    func pasteString() -> String? {
        UIPasteboard.general.string
    }
    
    func pasteImage() -> UIImage? {
        UIPasteboard.general.image
    }
    
    func hasString() -> Bool {
        UIPasteboard.general.hasStrings
    }
    
    func hasImage() -> Bool {
        UIPasteboard.general.hasImages
    }
    
    func clear() {
        UIPasteboard.general.items = []
    }
}

import UIKit