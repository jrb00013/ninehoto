import Foundation

final class ActivityIndicatorManager {
    static let shared = ActivityIndicatorManager()
    
    private var activeIndicators: [String: UIActivityIndicatorView] = [:]
    
    private init() {}
    
    func show(in view: UIView, key: String = "default", style: UIActivityIndicatorView.Style = .large) {
        DispatchQueue.main.async { [weak self] in
            guard self?.activeIndicators[key] == nil else { return }
            
            let indicator = UIActivityIndicatorView(style: style)
            indicator.center = view.center
            indicator.startAnimating()
            indicator.tag = key.hashValue
            
            view.addSubview(indicator)
            self?.activeIndicators[key] = indicator
        }
    }
    
    func hide(key: String = "default") {
        DispatchQueue.main.async { [weak self] in
            guard let indicator = self?.activeIndicators.removeValue(forKey: key) else { return }
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
    func hideAll() {
        DispatchQueue.main.async { [weak self] in
            self?.activeIndicators.values.forEach { $0.stopAnimating(); $0.removeFromSuperview() }
            self?.activeIndicators.removeAll()
        }
    }
}

import UIKit