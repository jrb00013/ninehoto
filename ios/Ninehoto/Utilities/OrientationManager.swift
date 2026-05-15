import Foundation

final class OrientationManager {
    static let shared = OrientationManager()
    
    private var supportedOrientations: UIInterfaceOrientationMask = .portrait
    
    private init() {}
    
    func setSupportedOrientations(_ orientations: UIInterfaceOrientationMask) {
        supportedOrientations = orientations
    }
    
    func lockToPortrait() {
        supportedOrientations = .portrait
    }
    
    func lockToLandscape() {
        supportedOrientations = .landscape
    }
    
    func unlockAll() {
        supportedOrientations = .all
    }
    
    var currentOrientation: UIInterfaceOrientation {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .unknown
        }
        return windowScene.interfaceOrientation
    }
    
    var isPortrait: Bool {
        currentOrientation == .portrait || currentOrientation == .portraitUpsideDown
    }
    
    var isLandscape: Bool {
        currentOrientation == .landscapeLeft || currentOrientation == .landscapeRight
    }
}

import UIKit