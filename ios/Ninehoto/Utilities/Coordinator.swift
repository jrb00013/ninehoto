import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

class CoordinatorBase: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    func start() {
        fatalError("Override start() in subclass")
    }
    
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}

final class AppCoordinator: CoordinatorBase {
    private let window: UIWindow
    private var navigationController: UINavigationController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() {
        let rootVC = MainMenuViewController()
        navigationController = UINavigationController(rootViewController: rootVC)
        navigationController?.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func showStatistics() {
        let statsVC = StatisticsViewController()
        navigationController?.pushViewController(statsVC, animated: true)
    }
    
    func showSwipeSession(with assets: [PHAsset]) {
        let swipeVC = SwipeSessionViewController(assets: assets)
        swipeVC.modalPresentationStyle = .fullScreen
        navigationController?.present(swipeVC, animated: true)
    }
}

import UIKit
import Photos