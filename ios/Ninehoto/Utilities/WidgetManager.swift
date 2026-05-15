import Foundation

final class WidgetManager {
    static let shared = WidgetManager()
    
    private init() {}
    
    func updateWidget(kind: String, info: [String: Any]) {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
    }
    
    func reloadAllWidgets() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

import WidgetKit