import Foundation

final class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    enum PermissionType {
        case photos
        case camera
        case microphone
        case location
        case notifications
    }
    
    enum PermissionStatus {
        case notDetermined
        case authorized
        case denied
        case restricted
    }
    
    func checkPermission(_ type: PermissionType) -> PermissionStatus {
        switch type {
        case .photos:
            return photoLibraryStatus()
        case .camera:
            return cameraStatus()
        case .notifications:
            return .notDetermined // use notificationPermissionStatus() (async)
        default:
            return .denied
        }
    }
    
    private func photoLibraryStatus() -> PermissionStatus {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined: return .notDetermined
        case .authorized, .limited: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
    
    private func cameraStatus() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
    
    func notificationPermissionStatus() async -> PermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        default: return .denied
        }
    }
    
    func requestPermission(_ type: PermissionType) async -> PermissionStatus {
        switch type {
        case .photos:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized || status == .limited ? .authorized : .denied
        case .camera:
            return await AVCaptureDevice.requestAccess(for: .video) ? .authorized : .denied
        case .notifications:
            let granted = await NotificationManager.shared.requestPermission()
            return granted ? .authorized : .denied
        default:
            return .denied
        }
    }
}

import AVFoundation
import Photos
import UserNotifications