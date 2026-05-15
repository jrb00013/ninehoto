import Foundation

final class AppPermissionsManager {
    static let shared = AppPermissionsManager()
    
    private init() {}
    
    struct PermissionStatus {
        let name: String
        let granted: Bool
        let canRequest: Bool
    }
    
    func getAllPermissionStatuses() -> [PermissionStatus] {
        [
            PermissionStatus(name: "Photos", granted: PermissionManager.shared.checkPermission(.photos) == .authorized, canRequest: true),
            PermissionStatus(name: "Camera", granted: PermissionManager.shared.checkPermission(.camera) == .authorized, canRequest: true),
            PermissionStatus(name: "Notifications", granted: PermissionManager.shared.checkPermission(.notifications) == .authorized, canRequest: true)
        ]
    }
    
    func requestAllPermissions() async {
        _ = await PermissionManager.shared.requestPermission(.photos)
        _ = await PermissionManager.shared.requestPermission(.notifications)
    }
    
    var allPermissionsGranted: Bool {
        getAllPermissionStatuses().allSatisfy { $0.granted }
    }
}